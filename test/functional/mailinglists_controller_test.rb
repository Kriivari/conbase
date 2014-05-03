require File.dirname(__FILE__) + '/../test_helper'
require 'mailinglists_controller'

# Re-raise errors caught by the controller.
class MailinglistsController; def rescue_action(e) raise e end; end

class MailinglistsControllerTest < Test::Unit::TestCase
  fixtures :mailinglists

  def setup
    @controller = MailinglistsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
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

    assert_not_nil assigns(:mailinglists)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:mailinglist)
    assert assigns(:mailinglist).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:mailinglist)
  end

  def test_create
    num_mailinglists = Mailinglist.count

    post :create, :mailinglist => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_mailinglists + 1, Mailinglist.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:mailinglist)
    assert assigns(:mailinglist).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Mailinglist.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Mailinglist.find(1)
    }
  end
end
