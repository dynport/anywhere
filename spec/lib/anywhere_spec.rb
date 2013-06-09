require "spec_helper"
require "anywhere"

describe "Anywhere" do
  subject(:anywhere) { Anywhere }
  it { should be_kind_of(Anywhere.class) }
  it { subject.logger.should_not be_nil }
end
