require "benchmark"
require "anywhere/logger"

module Anywhere
  class Base
    attr_writer :logger

    def logger
      @logger ||= Anywhere::Logger.new
    end

    def root?
      whoami == "root"
    end

    def capture(path, compressed = false)
      io = StringIO.new
      cmd = "cat #{path}"
      cmd << " | gzip " if compressed
      execute(cmd, nil, io)
      io.rewind
      out = io.read
      if compressed
        # not sure why this is not working with the uncompress method
        out, s = Open3.capture2("cat - | gunzip", stdin_data: out)
        out
      else
        out
      end
    end

    def uncompress(string)
      require "zlib"
      require "base64"
      zstream = Zlib::Inflate.new
      buf = zstream.inflate(string)
      zstream.finish
      zstream.close
      buf
    end

    def execute(cmd, stdin = nil, stdout = nil)
      do_execute(cmd, stdin, stdout) do |stream, data|
        data.split("\n").each do |line|
          if stream == :stderr
            logger.error line
          elsif !stdout
            logger.debug line
          end
        end
      end
    end

    def whoami
      @whoami ||= execute("whoami").stdout.strip
    end

    def do_execute(*args)
      raise "implement me in subclass"
    end

    def file_exists?(path)
      execute("test -e #{path}")
      true
    rescue Anywhere::ExecutionError => err
      if err.result.exit_status == 1
        false
      else
        raise
      end
    end

    def md5sum(path)
      execute("md5sum #{path} | awk '{ print $1 }'").stdout.strip
    end

    def sudo_cmd
      @sudo_cmd ||= root? ? "" : "sudo"
    end

    def add_system_user(login)
      raise "user #{login} already exists" if user_exists?(login)
      logger.info "adding system user #{login}"
      execute!("#{sudo_cmd} adduser --system #{login}")
    end

    def run_as(user, cmd)
      execute("sudo -- sudo -u #{user} -- #{cmd}")
    end

    def user_exists?(login)
      execute("id #{login} 2>/dev/null").success?
    end

    def write_file(path, content, attributes = {})
      md5 = Digest::MD5.hexdigest(content).to_s
      if file_exists?(path)
        logger.debug "file #{path} already exists"
        file_md5 = md5sum(path)
        if file_md5 == md5
          logger.info "file #{path} did not change => not writing"
          return :not_changed
        end
      end
      logger.info "writing #{content.length} bytes to #{path} (md5: #{md5})"
      tmp_path = "/tmp/anywhere/files.#{md5}"
      execute("#{sudo_cmd} mkdir -p #{File.dirname(tmp_path)}")
      execute("#{sudo_cmd} chown #{whoami} #{File.dirname(tmp_path)}")
      logger.debug "writing to #{tmp_path}"
      execute(%(rm -f #{tmp_path}; cat - > #{tmp_path}), content)
      if mode = attributes[:mode]
        logger.info "changing mode to #{mode}"
        execute("chmod #{mode} #{tmp_path}")
      end
      if owner = attributes[:owner]
        logger.info "changing owner to #{owner}"
        execute("#{sudo_cmd} chown #{owner} #{tmp_path}")
      end
      execute("#{sudo_cmd} mkdir -p #{File.dirname(path)}")
      logger.debug "moving #{tmp_path} to #{path}"
      if file_exists?(path)
        logger.debug "diff #{path} #{tmp_path}"
        execute("diff #{tmp_path} #{path}; /bin/true").stdout.split("\n").each do |line|
          logger.debug line
        end
      end
      execute("#{sudo_cmd} mv #{tmp_path} #{path}")
    end

    def extract_tar(path, dst)
      ms = Benchmark.measure do
        data = File.open(path, "rb") do |f|
          f.read
        end
        logger.info "writing #{data.length} bytes"
        execute(%(mkdir -p #{dst} && cd #{dst} && tar xfz -), data)
      end
      logger.info "extracted archive in %.3f" % [ms.real]
    end

    def mkdir_p(path)
      logger.info "creating directory #{path}"
      execute("mkdir -p #{path}")
    end

    def home_dir
      execute("env | grep HOME | cut -d = -f 2").stdout.strip
    end
  end
end
