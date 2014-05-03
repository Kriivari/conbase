require File.dirname(__FILE__) + '/../test_helper'
require 'notifications_controller'

# Re-raise errors caught by the controller.
class NotificationsController; def rescue_action(e) raise e end; end

class NotificationsControllerTest < Test::Unit::TestCase
  fixtures :notifications

  def setup
    @controller = NotificationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = notifications(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:notifications)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:notification)
    assert assigns(:notification).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:notification)
  end

  def test_create
    num_notifications = Notification.count

    post :create, :notification => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_notifications + 1, Notification.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:notification)
    assert assigns(:notification).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Notification.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Notification.find(@first_id)
    }
  end
end
