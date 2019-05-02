require 'spec_helper'

describe 'RailsAdmin Config DSL List Section', type: :request do
  subject { page }

  describe 'css hooks' do
    it 'is present' do
      RailsAdmin.config Team do
        list do
          field :name
        end
      end
      FactoryBot.create :team
      visit index_path(model_name: 'team')
      is_expected.to have_selector('th.header.string_type.name_field')
      is_expected.to have_selector('td.string_type.name_field')
    end
  end

  describe 'number of items per page' do
    before do
      2.times.each do
        FactoryBot.create :league
        FactoryBot.create :player
      end
    end

    it 'is configurable per model' do
      RailsAdmin.config League do
        list do
          items_per_page 1
        end
      end
      visit index_path(model_name: 'league')
      is_expected.to have_selector('tbody tr', count: 1)
      visit index_path(model_name: 'player')
      is_expected.to have_selector('tbody tr', count: 2)
    end
  end

  describe "items' fields" do
    it 'shows all by default' do
      visit index_path(model_name: 'fan')
      expect(all('th').collect(&:text).delete_if { |t| /^\n*$/ =~ t }).
        to match_array ['Id', 'Created at', 'Updated at', 'Their Name', 'Teams']
    end

    it 'hides some fields on demand with a block' do
      RailsAdmin.config Fan do
        list do
          exclude_fields_if do
            type == :datetime
          end
        end
      end
      visit index_path(model_name: 'fan')
      expect(all('th').collect(&:text).delete_if { |t| /^\n*$/ =~ t }).
        to match_array ['Id', 'Their Name', 'Teams']
    end

    it 'hides some fields on demand with fields list' do
      RailsAdmin.config Fan do
        list do
          exclude_fields :created_at, :updated_at
        end
      end
      visit index_path(model_name: 'fan')
      expect(all('th').collect(&:text).delete_if { |t| /^\n*$/ =~ t }).
        to match_array ['Id', 'Their Name', 'Teams']
    end

    it 'adds some fields on demand with a block' do
      RailsAdmin.config Fan do
        list do
          include_fields_if do
            type != :datetime
          end
        end
      end
      visit index_path(model_name: 'fan')
      expect(all('th').collect(&:text).delete_if { |t| /^\n*$/ =~ t }).
        to match_array ['Id', 'Their Name', 'Teams']
    end

    it 'shows some fields on demand with fields list, respect ordering and configure them' do
      RailsAdmin.config Fan do
        list do
          fields :name, PK_COLUMN do
            label do
              "Modified #{label}"
            end
          end
        end
      end
      visit index_path(model_name: 'fan')
      expect(all('th').collect(&:text).delete_if { |t| /^\n*$/ =~ t }).
        to match_array ['Modified Id', 'Modified Their Name']
    end

    it 'shows all fields if asked' do
      RailsAdmin.config Fan do
        list do
          include_all_fields
          field PK_COLUMN
          field :name
        end
      end
      visit index_path(model_name: 'fan')
      expect(all('th').collect(&:text).delete_if { |t| /^\n*$/ =~ t }).
        to match_array ['Id', 'Created at', 'Updated at', 'Their Name', 'Teams']
    end

    it 'appears in order defined' do
      RailsAdmin.config Fan do
        list do
          field :updated_at
          field :name
          field PK_COLUMN
          field :created_at
        end
      end
      visit index_path(model_name: 'fan')
      expect(all('th').collect(&:text).delete_if { |t| /^\n*$/ =~ t }).
        to eq(['Updated at', 'Their Name', 'Id', 'Created at'])
    end

    it 'only lists the defined fields if some fields are defined' do
      RailsAdmin.config Fan do
        list do
          field PK_COLUMN
          field :name
        end
      end
      visit index_path(model_name: 'fan')
      expect(all('th').collect(&:text).delete_if { |t| /^\n*$/ =~ t }).
        to eq(['Id', 'Their Name'])
      is_expected.to have_no_selector('th:nth-child(4).header')
    end

    it 'delegates the label option to the ActiveModel API' do
      RailsAdmin.config Fan do
        list do
          field :name
        end
      end
      visit index_path(model_name: 'fan')
      expect(find('th:nth-child(2)')).to have_content('Their Name')
    end

    it 'is renameable' do
      RailsAdmin.config Fan do
        list do
          field PK_COLUMN do
            label 'Identifier'
          end
          field :name
        end
      end
      visit index_path(model_name: 'fan')
      expect(find('th:nth-child(2)')).to have_content('Identifier')
      expect(find('th:nth-child(3)')).to have_content('Their Name')
    end

    it 'is renameable by type' do
      RailsAdmin.config Fan do
        list do
          fields_of_type :datetime do
            label { "#{label} (datetime)" }
          end
        end
      end
      visit index_path(model_name: 'fan')
      expect(all('th').collect(&:text).delete_if { |t| /^\n*$/ =~ t }).
        to match_array ['Id', 'Created at (datetime)', 'Updated at (datetime)', 'Their Name', 'Teams']
    end

    it 'is globally renameable by type' do
      RailsAdmin.config Fan do
        list do
          fields_of_type :datetime do
            label { "#{label} (datetime)" }
          end
        end
      end
      visit index_path(model_name: 'fan')
      expect(all('th').collect(&:text).delete_if { |t| /^\n*$/ =~ t }).
        to match_array ['Id', 'Created at (datetime)', 'Updated at (datetime)', 'Their Name', 'Teams']
    end

    it 'is sortable by default' do
      visit index_path(model_name: 'fan')
      is_expected.to have_selector('th:nth-child(2).header')
      is_expected.to have_selector('th:nth-child(3).header')
      is_expected.to have_selector('th:nth-child(4).header')
      is_expected.to have_selector('th:nth-child(5).header')
    end

    it 'has option to disable sortability' do
      RailsAdmin.config Fan do
        list do
          field PK_COLUMN do
            sortable false
          end
          field :name
        end
      end
      visit index_path(model_name: 'fan')
      is_expected.to have_no_selector('th:nth-child(2).header')
      is_expected.to have_selector('th:nth-child(3).header')
    end

    it 'has option to disable sortability by type' do
      RailsAdmin.config Fan do
        list do
          fields_of_type :datetime do
            sortable false
          end
          field PK_COLUMN
          field :name
          field :created_at
          field :updated_at
        end
      end
      visit index_path(model_name: 'fan')
      is_expected.to have_selector('th:nth-child(2).header')
      is_expected.to have_selector('th:nth-child(3).header')
      is_expected.to have_no_selector('th:nth-child(4).header')
      is_expected.to have_no_selector('th:nth-child(5).header')
    end

    it 'has option to disable sortability by type globally' do
      RailsAdmin.config Fan do
        list do
          fields_of_type :datetime do
            sortable false
          end
          field PK_COLUMN
          field :name
          field :created_at
          field :updated_at
        end
      end
      visit index_path(model_name: 'fan')
      is_expected.to have_selector('th:nth-child(2).header')
      is_expected.to have_selector('th:nth-child(3).header')
      is_expected.to have_no_selector('th:nth-child(4).header')
      is_expected.to have_no_selector('th:nth-child(5).header')
    end

    it 'has option to hide fields by type' do
      RailsAdmin.config Fan do
        list do
          fields_of_type :datetime do
            hide
          end
        end
      end
      visit index_path(model_name: 'fan')
      expect(all('th').collect(&:text).delete_if { |t| /^\n*$/ =~ t }).
        to match_array ['Id', 'Their Name', 'Teams']
    end

    it 'has option to hide fields by type globally' do
      RailsAdmin.config Fan do
        list do
          fields_of_type :datetime do
            hide
          end
        end
      end
      visit index_path(model_name: 'fan')
      expect(all('th').collect(&:text).delete_if { |t| /^\n*$/ =~ t }).
        to match_array ['Id', 'Their Name', 'Teams']
    end

    it 'has option to customize column width' do
      RailsAdmin.config Fan do
        list do
          field PK_COLUMN do
            column_width 200
          end
          field :name
          field :created_at
          field :updated_at
        end
      end
      @fans = FactoryBot.create_list(:fan, 2)
      visit index_path(model_name: 'fan')
      # NOTE: Capybara really doesn't want us to look at invisible text. This test
      # could break at any moment.
      expect(find('style').native.text).to include("#list th.#{PK_COLUMN}_field")
      expect(find('style').native.text).to include("#list td.#{PK_COLUMN}_field")
    end

    it 'has option to customize output formatting' do
      RailsAdmin.config Fan do
        list do
          field PK_COLUMN
          field :name do
            formatted_value do
              value.to_s.upcase
            end
          end
          field :created_at
          field :updated_at
        end
      end
      @fans = FactoryBot.create_list(:fan, 2).sort_by(&:id)
      visit index_path(model_name: 'fan')
      expect(find('tbody tr:nth-child(1) td:nth-child(3)')).to have_content(@fans[1].name.upcase)
      expect(find('tbody tr:nth-child(2) td:nth-child(3)')).to have_content(@fans[0].name.upcase)
    end

    it 'has a simple option to customize output formatting of date fields' do
      RailsAdmin.config Fan do
        list do
          field PK_COLUMN
          field :name
          field :created_at do
            date_format :short
          end
          field :updated_at
        end
      end
      @fans = FactoryBot.create_list(:fan, 2)
      visit index_path(model_name: 'fan')
      is_expected.to have_selector('tbody tr:nth-child(1) td:nth-child(4)', text: /\d{2} \w{3} \d{1,2}:\d{1,2}/)
    end

    it 'has option to customize output formatting of date fields' do
      RailsAdmin.config Fan do
        list do
          field PK_COLUMN
          field :name
          field :created_at do
            strftime_format '%Y-%m-%d'
          end
          field :updated_at
        end
      end
      @fans = FactoryBot.create_list(:fan, 2)
      visit index_path(model_name: 'fan')
      is_expected.to have_selector('tbody tr:nth-child(1) td:nth-child(4)', text: /\d{4}-\d{2}-\d{2}/)
    end

    it 'allows addition of virtual fields (object methods)' do
      RailsAdmin.config Team do
        list do
          field PK_COLUMN
          field :name
          field :player_names_truncated
        end
      end
      @team = FactoryBot.create :team
      @players = FactoryBot.create_list :player, 2, team: @team
      visit index_path(model_name: 'team')
      expect(find('tbody tr:nth-child(1) td:nth-child(4)')).to have_content(@players.sort_by(&:id).collect(&:name).join(', '))
    end
  end

  # sort_by and sort_reverse options
  describe 'default sorting' do
    let(:today) { Date.today }
    let(:players) do
      [{name: 'Jackie Robinson',  created_at: today,            team_id: rand(99_999), number: 42},
       {name: 'Deibinson Romero', created_at: (today - 2.days), team_id: rand(99_999), number: 13},
       {name: 'Sandy Koufax',     created_at: (today - 1.days), team_id: rand(99_999), number: 32}]
    end
    let(:leagues) do
      [{name: 'American',      created_at: (today - 1.day)},
       {name: 'Florida State', created_at: (today - 2.days)},
       {name: 'National',      created_at: today}]
    end
    let(:player_names_by_date) { players.sort_by { |p| p[:created_at] }.collect { |p| p[:name] } }
    let(:league_names_by_date) { leagues.sort_by { |l| l[:created_at] }.collect { |l| l[:name] } }

    before { @players = players.collect { |h| Player.create(h) } }

    context 'should be configurable' do
      it 'per model' do
        RailsAdmin.config Player do
          list do
            sort_by :created_at
            sort_reverse true
            field :name
          end
        end
        visit index_path(model_name: 'player')
        player_names_by_date.reverse.each_with_index do |name, i|
          expect(find("tbody tr:nth-child(#{i + 1})")).to have_content(name)
        end
      end
    end

    it 'has reverse direction by default' do
      RailsAdmin.config Player do
        list do
          sort_by :created_at
          field :name
        end
      end
      visit index_path(model_name: 'player')
      player_names_by_date.reverse.each_with_index do |name, i|
        expect(find("tbody tr:nth-child(#{i + 1})")).to have_content(name)
      end
    end

    it 'allows change default direction' do
      RailsAdmin.config Player do
        list do
          sort_by :created_at
          sort_reverse false
          field :name
        end
      end
      visit index_path(model_name: 'player')
      player_names_by_date.each_with_index do |name, i|
        expect(find("tbody tr:nth-child(#{i + 1})")).to have_content(name)
      end
    end
  end

  describe 'embedded model', mongoid: true do
    it "does not show link to individual object's page" do
      RailsAdmin.config FieldTest do
        list do
          field :embeds
        end
      end
      @record = FactoryBot.create :field_test
      2.times.each { |i| @record.embeds.create name: "embed #{i}" }
      visit index_path(model_name: 'field_test')
      is_expected.not_to have_link('embed 0')
      is_expected.not_to have_link('embed 1')
    end
  end

  describe 'checkboxes?' do
    describe 'default is enabled' do
      before do
        RailsAdmin.config FieldTest do
          list
        end
      end

      it 'displays checkboxes on index' do
        @records = FactoryBot.create_list :field_test, 3

        visit index_path(model_name: 'field_test')
        checkboxes = all(:xpath, './/form[@id="bulk_form"]//input[@type="checkbox"]')
        expect(checkboxes.length).to be > 0

        expect(page).to have_content('Selected items')
      end
    end

    describe 'false' do
      before do
        RailsAdmin.config FieldTest do
          list do
            checkboxes false
          end
        end
      end

      it 'does not display any checkboxes on index' do
        @records = FactoryBot.create_list :field_test, 3

        visit index_path(model_name: 'field_test')
        checkboxes = all(:xpath, './/form[@id="bulk_form"]//input[@type="checkbox"]')
        expect(checkboxes.length).to eq 0

        expect(page).not_to have_content('Selected items')
      end
    end
  end

  describe 'sidescroll list option' do
    all_team_columns = ['', '', 'Id', 'Created at', 'Updated at', 'Division', 'Name', 'Logo url', 'Team Manager', 'Ballpark', 'Mascot', 'Founded', 'Wins', 'Losses', 'Win percentage', 'Revenue', 'Color', 'Custom field', 'Main Sponsor', 'Players', 'Some Fans', 'Comments']

    it "displays all fields on one page when true" do
      RailsAdmin.config do |config|
        config.sidescroll = true
      end
      FactoryBot.create_list :team, 3
      visit index_path(model_name: 'team')
      cols = all('th').collect(&:text)
      expect(cols[0..4]).to eq(all_team_columns[0..4])
      expect(cols).to contain_exactly(*all_team_columns)
      expect(page).to have_selector('.table-wrapper.ra-sidescroll-table')
      expect(page).to have_selector('.ra-sidescroll')
      expect(all('.ra-sidescroll-frozen').count).to eq(12)
      expect(all('th.ra-sidescroll-frozen').count).to eq(3)
      expect(all('td.ra-sidescroll-frozen').count).to eq(9)
      expect(all('.ra-sidescroll-frozen-last').count).to eq(4)
    end

    it "displays all fields with custom frozen columns" do
      RailsAdmin.config do |config|
        config.sidescroll = {num_frozen_columns: 2}
      end
      FactoryBot.create_list :team, 3
      visit index_path(model_name: 'team')
      cols = all('th').collect(&:text)
      expect(cols[0..4]).to eq(all_team_columns[0..4])
      expect(cols).to contain_exactly(*all_team_columns)
      expect(page).to have_selector('.table-wrapper.ra-sidescroll-table')
      expect(page).to have_selector('.ra-sidescroll')
      expect(all('.ra-sidescroll-frozen').count).to eq(8)
      expect(all('th.ra-sidescroll-frozen').count).to eq(2)
      expect(all('td.ra-sidescroll-frozen').count).to eq(6)
      expect(all('.ra-sidescroll-frozen-last').count).to eq(4)
    end

    it "displays all fields with no checkboxes" do
      RailsAdmin.config do |config|
        config.sidescroll = true
      end
      RailsAdmin.config Team do
        list do
          checkboxes false
        end
      end
      FactoryBot.create_list :team, 3
      visit index_path(model_name: 'team')
      cols = all('th').collect(&:text)
      expect(cols[0..3]).to eq(all_team_columns[1..4])
      expect(cols).to contain_exactly(*all_team_columns[1..-1])
      expect(all('.ra-sidescroll-frozen').count).to eq(8)
      expect(all('th.ra-sidescroll-frozen').count).to eq(2)
      expect(all('td.ra-sidescroll-frozen').count).to eq(6)
      expect(all('.ra-sidescroll-frozen-last').count).to eq(4)
    end

    it "displays all fields with no frozen columns" do
      RailsAdmin.config do |config|
        config.sidescroll = {num_frozen_columns: 0}
      end
      FactoryBot.create_list :team, 3
      visit index_path(model_name: 'team')
      cols = all('th').collect(&:text)
      expect(cols[0..4]).to eq(all_team_columns[0..4])
      expect(cols).to contain_exactly(*all_team_columns)
      expect(page).to have_selector('.table-wrapper.ra-sidescroll-table')
      expect(page).not_to have_selector('.ra-sidescroll')
      expect(all('.ra-sidescroll-frozen').count).to eq(0)
      expect(all('.ra-sidescroll-frozen-last').count).to eq(0)
    end

    it "displays sets when not set" do
      visit index_path(model_name: 'team')
      expect(all('th').collect(&:text)).to eq ['', 'Id', 'Created at', 'Updated at', 'Division', 'Name', 'Logo url', '...', '']
      expect(page).to have_selector('.table-wrapper')
      expect(page).not_to have_selector('.table-wrapper.ra-sidescroll-table')
      expect(page).not_to have_selector('.ra-sidescroll')
      expect(all('.ra-sidescroll-frozen').count).to eq(0)
      expect(all('.ra-sidescroll-frozen-last').count).to eq(0)
    end

    it "displays sets when global config is on but model config is off" do
      RailsAdmin.config do |config|
        config.sidescroll = true
      end
      RailsAdmin.config Team do
        list do
          sidescroll false
        end
      end
      visit index_path(model_name: 'team')
      expect(all('th').collect(&:text)).to eq ['', 'Id', 'Created at', 'Updated at', 'Division', 'Name', 'Logo url', '...', '']
      expect(page).to have_selector('.table-wrapper')
      expect(page).not_to have_selector('.table-wrapper.ra-sidescroll-table')
      expect(page).not_to have_selector('.ra-sidescroll')
      expect(all('.ra-sidescroll-frozen').count).to eq(0)
      expect(all('.ra-sidescroll-frozen-last').count).to eq(0)
    end

    it "displays all fields when global config is off but model config is on" do
      RailsAdmin.config Team do
        list do
          sidescroll true
        end
      end
      FactoryBot.create_list :team, 3
      visit index_path(model_name: 'team')
      cols = all('th').collect(&:text)
      expect(cols[0..4]).to eq(all_team_columns[0..4])
      expect(cols).to contain_exactly(*all_team_columns)
      expect(page).to have_selector('.table-wrapper.ra-sidescroll-table')
      expect(page).to have_selector('.ra-sidescroll')
      expect(all('.ra-sidescroll-frozen').count).to eq(12)
      expect(all('th.ra-sidescroll-frozen').count).to eq(3)
      expect(all('td.ra-sidescroll-frozen').count).to eq(9)
      expect(all('.ra-sidescroll-frozen-last').count).to eq(4)
    end

    it "displays all fields with custom model config settings" do
      RailsAdmin.config do |config|
        config.sidescroll = true
      end
      RailsAdmin.config Team do
        list do
          sidescroll(num_frozen_columns: 2)
        end
      end
      FactoryBot.create_list :team, 3
      FactoryBot.create_list :player, 3
      visit index_path(model_name: 'team')
      cols = all('th').collect(&:text)
      expect(cols[0..4]).to eq(all_team_columns[0..4])
      expect(cols).to contain_exactly(*all_team_columns)
      expect(page).to have_selector('.table-wrapper.ra-sidescroll-table')
      expect(page).to have_selector('.ra-sidescroll')
      expect(all('.ra-sidescroll-frozen').count).to eq(8)
      expect(all('th.ra-sidescroll-frozen').count).to eq(2)
      expect(all('td.ra-sidescroll-frozen').count).to eq(6)
      expect(all('.ra-sidescroll-frozen-last').count).to eq(4)
      visit index_path(model_name: 'player')
      expect(page).to have_selector('.table-wrapper.ra-sidescroll-table')
      expect(page).to have_selector('.ra-sidescroll')
      expect(all('.ra-sidescroll-frozen').count).to eq(12)
      expect(all('th.ra-sidescroll-frozen').count).to eq(3)
      expect(all('td.ra-sidescroll-frozen').count).to eq(9)
      expect(all('.ra-sidescroll-frozen-last').count).to eq(4)
    end

    it "displays all fields with model config checkbox settings" do
      RailsAdmin.config do |config|
        config.sidescroll = true
      end
      RailsAdmin.config Team do
        list do
          sidescroll(num_frozen_columns: 3)
          checkboxes false
        end
      end
      FactoryBot.create_list :team, 3
      visit index_path(model_name: 'team')
      cols = all('th').collect(&:text)
      expect(cols[0..3]).to eq(all_team_columns[1..4])
      expect(cols).to contain_exactly(*all_team_columns[1..-1])
      expect(page).to have_selector('.table-wrapper.ra-sidescroll-table')
      expect(page).to have_selector('.ra-sidescroll')
      expect(all('.ra-sidescroll-frozen').count).to eq(12)
      expect(all('th.ra-sidescroll-frozen').count).to eq(3)
      expect(all('td.ra-sidescroll-frozen').count).to eq(9)
      expect(all('.ra-sidescroll-frozen-last').count).to eq(4)
    end
  end
end
