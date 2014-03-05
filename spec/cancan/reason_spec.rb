require 'spec_helper'
require "ostruct"

describe CanCan::Reason do
  before :all do
    class Article < OpenStruct
    end

    class Ability
      include CanCan::Ability
    end
  end

  context 'Conditons are Hash' do
    before do
      Ability.class_eval do
        # override by lower one
        # https://github.com/ryanb/cancan/wiki/Ability-Precedence
        define_method :initialize do |user|
          cannot :read, Article, because: "Private article"
          can :read, Article, author: user
          can :read, Article, public: true
          cannot :read, Article, removed: true, because: "Removed"
        end
      end
    end

    let (:user) { Object.new }
    let (:removed_article) { Article.new(removed: true, author: user) }
    let (:private_article) { Article.new(public: false) }
    let (:ability) { Ability.new(user) }

    context 'Reject by last cannot statement' do
      it "shoud have reason defined in last cannot statement" do
        ability.can?(:read, removed_article).should be_false
        ability.reason(:read, removed_article).should == "Removed"
      end
    end

    context 'Reject by first cannot statement' do
      it "shoud have reason defined in first cannot statement" do
        ability.can?(:read, private_article).should be_false
        ability.reason(:read, private_article).should == "Private article"
      end
    end
  end

  it 'should have a version number' do
    CanCan::Reason::VERSION.should_not be_nil
  end
end
