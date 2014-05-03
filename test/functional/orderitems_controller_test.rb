require File.dirname(__FILE__) + '/../test_helper'
require 'orderitems_controller'

# Re-raise errors caught by the controller.
class OrderitemsController; def rescue_action(e) raise e end; end

class OrderitemsControllerTest < Test::Unit::TestCase
  fixtures :orderitems

  def setup
    @controller = OrderitemsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = orderitems(:first).id
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

    assert_not_nil assigns(:orderitems)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:orderitem)
    assert assigns(:orderitem).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:orderitem)
  end

  def test_create
    num_orderitems = Orderitem.count

    post :create, :orderitem => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_orderitems + 1, Orderitem.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:orderitem)
    assert assigns(:orderitem).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Orderitem.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Orderitem.find(@first_id)
    }
  end
end
