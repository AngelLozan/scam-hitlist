# frozen_string_literal: true

require 'test_helper'

class IocsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ioc = iocs(:one)
  end

  test 'should get index' do
    get iocs_url
    assert_response :success
  end

  test 'should get new' do
    get new_ioc_url
    assert_response :success
  end

  test 'should create ioc' do
    assert_difference('Ioc.count') do
      post iocs_url,
           params: { ioc: { comments: @ioc.comments, follow_up_count: @ioc.follow_up_count, follow_up_date: @ioc.follow_up_date,
                            form: @ioc.form, host: @ioc.host, removed_date: @ioc.removed_date, report_method_one: @ioc.report_method_one, report_method_two: @ioc.report_method_two, url: @ioc.url } }
    end

    assert_redirected_to ioc_url(Ioc.last)
  end

  test 'should show ioc' do
    get ioc_url(@ioc)
    assert_response :success
  end

  test 'should get edit' do
    get edit_ioc_url(@ioc)
    assert_response :success
  end

  test 'should update ioc' do
    patch ioc_url(@ioc),
          params: { ioc: { comments: @ioc.comments, follow_up_count: @ioc.follow_up_count, follow_up_date: @ioc.follow_up_date,
                           form: @ioc.form, host: @ioc.host, removed_date: @ioc.removed_date, report_method_one: @ioc.report_method_one, report_method_two: @ioc.report_method_two, url: @ioc.url } }
    assert_redirected_to ioc_url(@ioc)
  end

  test 'should destroy ioc' do
    assert_difference('Ioc.count', -1) do
      delete ioc_url(@ioc)
    end

    assert_redirected_to iocs_url
  end
end
