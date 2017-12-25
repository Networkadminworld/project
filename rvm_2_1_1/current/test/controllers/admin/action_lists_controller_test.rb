require 'test_helper'

class Admin::ActionListsControllerTest < ActionController::TestCase
  setup do
    @admin_action_list = admin_action_lists(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_action_lists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_action_list" do
    assert_difference('Admin::ActionList.count') do
      post :create, admin_action_list: {  }
    end

    assert_redirected_to admin_action_list_path(assigns(:admin_action_list))
  end

  test "should show admin_action_list" do
    get :show, id: @admin_action_list
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_action_list
    assert_response :success
  end

  test "should update admin_action_list" do
    patch :update, id: @admin_action_list, admin_action_list: {  }
    assert_redirected_to admin_action_list_path(assigns(:admin_action_list))
  end

  test "should destroy admin_action_list" do
    assert_difference('Admin::ActionList.count', -1) do
      delete :destroy, id: @admin_action_list
    end

    assert_redirected_to admin_action_lists_path
  end
end
