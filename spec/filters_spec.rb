require 'spec_helper'

RSpec.describe "::Filters::Filters" do

  context "Filter" do
    it "get array of filters" do
      query = "id==1234,label==Damir"
      @filterer = ::Filters::Filters.new(query)
      expect(@filterer.get.length).to eq 2
      expect(@filterer.has?('id')).to eq true
      expect(@filterer.has?('foobar')).to eq false
      expect(@filterer.get('id')[:value]).to eq '1234'
      expect(@filterer.get('foobar')).to eq nil

      @filterer = ::Filters::Filters.new(nil)
      expect(@filterer.get).to eq []
      expect(@filterer.has?('source.id')).to eq false
    end

    it "converts query string to an array filter hashes" do
      query = "source.id==1234,source.label==Damir"
      @filterer = ::Filters::Filters.new(query)
      expect(@filterer.get.length).to eq 2
      expect(@filterer.get("source.id")[:field]).to eq "source.id"
      expect(@filterer.get("source.id")[:operator]).to eq "=="
      expect(@filterer.get("source.id")[:value]).to eq '1234'
    end

    it "handles compound expressions" do
      query = "source.id==1234,source.label==Damir,cost><400;1000,price>=<500;1100"
      @filterer = ::Filters::Filters.new(query)
      expect(@filterer.get.length).to eq 4
      expect(@filterer.get("cost")[:field]).to eq "cost"
      expect(@filterer.get("cost")[:operator]).to eq "><"
      expect(@filterer.get("cost")[:value]).to eq ['400', '1000']
      expect(@filterer.get("price")[:value]).to eq ['500', '1100']
    end

    it "ignores escaped characters" do
      query = 'full_name_last_first==Montoya\\,Inigo,service==Army\\\Navy'
      @filterer = ::Filters::Filters.new(query)
      expect(@filterer.get("full_name_last_first")[:field]).to eq "full_name_last_first"
      expect(@filterer.get("full_name_last_first")[:operator]).to eq "=="
      expect(@filterer.get("full_name_last_first")[:value]).to eq 'Montoya\,Inigo'
      expect(@filterer.get("service")[:value]).to eq 'Army\\\Navy' #interpreted as 'Army\\Navy' - Ruby parses string and escapes
    end

    it "converts filters to sql" do
      query = "id==1234,label==Damir,cost><400;1000,price>=<500;1100"
      @filterer = ::Filters::Filters.new(query)
      expect(@filterer.get('id')[:sql]).to eq "id = '1234'"
      expect(@filterer.get('label')[:sql]).to eq "label = 'Damir'"
      expect(@filterer.get('cost')[:sql]).to eq "cost > '400' AND cost < '1000'"
      expect(@filterer.get('price')[:sql]).to eq "price BETWEEN '500' AND '1100'"
    end

    it "converts filters to safe_sql" do
      query = "id==1234,label==Damir,cost><400;1000,price>=<500;1100"
      @filterer = ::Filters::Filters.new(query)
      expect(@filterer.get('id')[:safe_sql]).to eq "id = ?"
      expect(@filterer.get('label')[:safe_sql]).to eq "label = ?"
      expect(@filterer.get('cost')[:safe_sql]).to eq "cost > ? AND cost < ?"
      expect(@filterer.get('price')[:safe_sql]).to eq "price BETWEEN ? AND ?"
      expect(@filterer.get('id')[:bindings]).to eq ['1234']
      expect(@filterer.get('label')[:bindings]).to eq ['Damir']
      expect(@filterer.get('cost')[:bindings]).to eq ['400', '1000']
      expect(@filterer.get('price')[:bindings]).to eq ['500', '1100']
    end

    it "queries numbers" do
      query = 'id>=<5;10'
      @filterer = ::Filters::Filters.new(query)
      sql = @filterer.get('id')[:sql]
      expect( sql ).to eq "id BETWEEN '5' AND '10'"

      query = 'id==5'
      @filterer = ::Filters::Filters.new(query)
      sql = @filterer.get('id')[:sql]
      expect( sql ).to eq "id = '5'"
    end

    it "queries dates" do
      query = "date><1955-11-04;1955-11-06"
      @filterer = ::Filters::Filters.new(query)
      sql = @filterer.get('date')[:sql]
      expect( sql ).to eq "date > '1955-11-04' AND date < '1955-11-06'"
    end
  end
end
