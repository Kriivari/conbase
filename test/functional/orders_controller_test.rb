require File.dirname(__FILE__) + '/../test_helper'
require 'orders_controller'

# Re-raise errors caught by the controller.
class OrdersController; def rescue_action(e) raise e end; end

class OrdersControllerTest < Test::Unit::TestCase
  fixtures :orders

  def setup
    @controller = OrdersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = orders(:first).id
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

    assert_not_nil assigns(:orders)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:order)
    assert assigns(:order).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:order)
  end

  def test_create
    num_orders = Order.count

    post :create, :order => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_orders + 1, Order.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:order)
    assert assigns(:order).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Order.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Order.find(@first_id)
    }
  end
end
