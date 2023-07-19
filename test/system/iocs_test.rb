# frozen_string_literal: true

require 'application_system_test_case'

class IocsTest < ApplicationSystemTestCase
  setup do
    @ioc = iocs(:one)
  end

  test 'visiting the index' do
    visit iocs_url
    assert_selector 'h1', text: 'Iocs'
  end

  test 'should create ioc' do
    visit iocs_url
    click_on 'New ioc'

    fill_in 'Comments', with: @ioc.comments
    fill_in 'Follow up count', with: @ioc.follow_up_count
    fill_in 'Follow up date', with: @ioc.follow_up_date
    fill_in 'Form', with: @ioc.form
    fill_in 'Host', with: @ioc.host
    fill_in 'Removed date', with: @ioc.removed_date
    fill_in 'Report method one', with: @ioc.report_method_one
    fill_in 'Report method two', with: @ioc.report_method_two
    fill_in 'Url', with: @ioc.url
    click_on 'Create Ioc'

    assert_text 'Ioc was successfully created'
    click_on 'Back'
  end

  test 'should update Ioc' do
    visit ioc_url(@ioc)
    click_on 'Edit this ioc', match: :first

    fill_in 'Comments', with: @ioc.comments
    fill_in 'Follow up count', with: @ioc.follow_up_count
    fill_in 'Follow up date', with: @ioc.follow_up_date
    fill_in 'Form', with: @ioc.form
    fill_in 'Host', with: @ioc.host
    fill_in 'Removed date', with: @ioc.removed_date
    fill_in 'Report method one', with: @ioc.report_method_one
    fill_in 'Report method two', with: @ioc.report_method_two
    fill_in 'Url', with: @ioc.url
    click_on 'Update Ioc'

    assert_text 'Ioc was successfully updated'
    click_on 'Back'
  end

  test 'should destroy Ioc' do
    visit ioc_url(@ioc)
    click_on 'Destroy this ioc', match: :first

    assert_text 'Ioc was successfully destroyed'
  end
end
