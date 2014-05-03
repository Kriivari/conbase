# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130730183000) do

  create_table "attribute_values", :force => true do |t|
    t.integer "attribute_id",                :null => false
    t.string  "value",        :limit => 100
    t.boolean "defaultvalue"
    t.boolean "visible"
  end

  create_table "attributes", :force => true do |t|
    t.string  "name",    :limit => 50
    t.boolean "visible"
    t.boolean "person"
    t.boolean "program"
    t.boolean "orders"
  end

  create_table "contacts", :force => true do |t|
    t.integer "person_id"
    t.integer "contact_type"
    t.string  "contact_value", :limit => 50
  end

  create_table "events", :force => true do |t|
    t.string   "name",         :limit => 50
    t.integer  "year"
    t.datetime "starttime"
    t.datetime "endtime"
    t.boolean  "ispublic"
    t.text     "footer"
    t.text     "registration"
    t.boolean  "ticketorder"
    t.string   "ticketfooter"
    t.string   "address"
    t.string   "bankaccount"
    t.string   "businesscode"
  end

  create_table "exhibitors", :force => true do |t|
    t.integer "person_id"
    t.text    "companyname"
    t.text    "publicname"
    t.text    "notes"
    t.integer "event_id"
    t.text    "description"
    t.integer "rebate"
    t.float   "paid"
    t.date    "invoicedate"
    t.date    "duedate"
    t.string  "billing_address"
  end

  create_table "exhibitors_product_types", :id => false, :force => true do |t|
    t.integer "product_type_id"
    t.integer "exhibitor_id"
  end

  create_table "locations", :force => true do |t|
    t.integer  "event_id",                  :null => false
    t.string   "name",       :limit => 100
    t.text     "notes"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "multiple"
  end

  create_table "mailinglists", :force => true do |t|
    t.integer "parent_id"
    t.string  "name",       :limit => 50
    t.string  "address",    :limit => 100
    t.boolean "autoadd"
    t.boolean "autodelete"
    t.boolean "autoupdate"
    t.text    "notes"
    t.text    "template"
  end

  create_table "notes", :force => true do |t|
    t.text     "title"
    t.text     "body"
    t.datetime "starttime"
    t.datetime "endtime"
    t.integer  "event_id"
    t.boolean  "important"
  end

  create_table "orderitems", :force => true do |t|
    t.integer  "order_id"
    t.text     "name"
    t.text     "location"
    t.float    "cost"
    t.integer  "status"
    t.text     "notes"
    t.datetime "deliverydate"
    t.float    "maxcost"
    t.float    "actualcost"
  end

  create_table "orders", :force => true do |t|
    t.integer  "event_id"
    t.integer  "person_id"
    t.text     "name"
    t.text     "destination"
    t.text     "notes"
    t.datetime "needed"
    t.integer  "owner_id"
    t.datetime "released"
    t.integer  "status"
    t.text     "commentlog"
  end

  create_table "orders_attributes", :force => true do |t|
    t.integer "order_id"
    t.integer "attribute_id"
    t.text    "value"
    t.text    "notes"
  end

  create_table "people", :force => true do |t|
    t.string   "firstname",     :limit => 30
    t.string   "lastname",      :limit => 30
    t.string   "nickname",      :limit => 30
    t.string   "street",        :limit => 50
    t.string   "zipcode",       :limit => 10
    t.string   "city",          :limit => 30
    t.string   "country",       :limit => 30
    t.text     "notes"
    t.string   "primary_email", :limit => 50
    t.integer  "birthyear"
    t.string   "picture_url"
    t.string   "photo_url"
    t.text     "cv"
    t.text     "old_id"
    t.string   "shirttext",     :limit => 30
    t.datetime "created_at"
    t.datetime "modified_at"
    t.text     "primary_phone"
    t.text     "password"
  end

  add_index "people", ["primary_email"], :name => "people_primary_email_key", :unique => true

  create_table "people_events_attributes", :force => true do |t|
    t.integer "person_id",                   :null => false
    t.integer "event_id",                    :null => false
    t.integer "attribute_id",                :null => false
    t.string  "value",        :limit => 100
    t.text    "notes"
  end

  create_table "people_persongroups", :force => true do |t|
    t.integer  "person_id",      :null => false
    t.integer  "persongroup_id", :null => false
    t.integer  "status"
    t.datetime "created_at"
  end

  create_table "persongroups", :force => true do |t|
    t.integer "event_id",                                        :null => false
    t.string  "name",           :limit => 50
    t.integer "mailinglist_id"
    t.integer "days"
    t.integer "food"
    t.boolean "visible"
    t.text    "notes"
    t.boolean "continues"
    t.boolean "admin"
    t.boolean "insurance"
    t.text    "welcomesubject"
    t.text    "adminemail"
    t.boolean "wikiaccess",                   :default => false
    t.text    "footer"
    t.boolean "nonstaff",                     :default => false
    t.text    "description"
  end

  create_table "pga_diagrams", :id => false, :force => true do |t|
    t.string "diagramname",   :limit => 64, :null => false
    t.text   "diagramtables"
    t.text   "diagramlinks"
  end

  create_table "pga_forms", :id => false, :force => true do |t|
    t.string "formname",   :limit => 64, :null => false
    t.text   "formsource"
  end

  create_table "pga_graphs", :id => false, :force => true do |t|
    t.string "graphname",   :limit => 64, :null => false
    t.text   "graphsource"
    t.text   "graphcode"
  end

  create_table "pga_images", :id => false, :force => true do |t|
    t.string "imagename",   :limit => 64, :null => false
    t.text   "imagesource"
  end

  create_table "pga_layout", :id => false, :force => true do |t|
    t.string  "tablename", :limit => 64, :null => false
    t.integer "nrcols",    :limit => 2
    t.text    "colnames"
    t.text    "colwidth"
  end

  create_table "pga_queries", :id => false, :force => true do |t|
    t.string "queryname",     :limit => 64, :null => false
    t.string "querytype",     :limit => 1
    t.text   "querycommand"
    t.text   "querytables"
    t.text   "querylinks"
    t.text   "queryresults"
    t.text   "querycomments"
  end

  create_table "pga_reports", :id => false, :force => true do |t|
    t.string "reportname",    :limit => 64, :null => false
    t.text   "reportsource"
    t.text   "reportbody"
    t.text   "reportprocs"
    t.text   "reportoptions"
  end

  create_table "pga_scripts", :id => false, :force => true do |t|
    t.string "scriptname",   :limit => 64, :null => false
    t.text   "scriptsource"
  end

  create_table "product_items_purchases", :id => false, :force => true do |t|
    t.integer "product_item_id"
    t.integer "purchase_id"
  end

  create_table "product_types", :force => true do |t|
    t.string   "name"
    t.boolean  "valid"
    t.float    "price"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "product_id"
    t.float    "secondprice"
  end

  create_table "products", :force => true do |t|
    t.string   "name"
    t.boolean  "valid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "program_languages", :force => true do |t|
    t.integer "program_id"
    t.string  "language",    :limit => 20
    t.text    "name"
    t.text    "description"
    t.text    "publicnotes"
  end

  create_table "programgroups", :force => true do |t|
    t.string  "name",           :limit => 50
    t.boolean "visible"
    t.integer "mailinglist_id"
    t.text    "old_id"
    t.boolean "primarygroup",                 :default => false
    t.string  "nameen",         :limit => 50
  end

  create_table "programitem_languages", :force => true do |t|
    t.integer "programitem_id"
    t.string  "language",       :limit => 20
    t.text    "name"
    t.text    "description"
  end

  create_table "programitems", :force => true do |t|
    t.integer  "program_id",                 :null => false
    t.string   "name",        :limit => 100
    t.text     "description"
    t.integer  "location_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.text     "old_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "programitems", ["end_time"], :name => "endtime_idx"
  add_index "programitems", ["start_time"], :name => "starttime_idx"

  create_table "programs", :force => true do |t|
    t.integer  "event_id",                    :null => false
    t.string   "name",         :limit => 100
    t.text     "description"
    t.text     "publicnotes"
    t.text     "privatenotes"
    t.integer  "attendance"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "url"
  end

  create_table "programs_events_attributes", :force => true do |t|
    t.integer "program_id",                  :null => false
    t.integer "event_id",                    :null => false
    t.integer "attribute_id",                :null => false
    t.string  "value",        :limit => 100
  end

  create_table "programs_organizers", :force => true do |t|
    t.integer "program_id", :null => false
    t.integer "person_id",  :null => false
    t.integer "orgtype"
  end

  create_table "programs_programgroups", :id => false, :force => true do |t|
    t.integer "program_id",      :null => false
    t.integer "programgroup_id", :null => false
  end

  create_table "purchases", :force => true do |t|
    t.string   "notes"
    t.float    "paid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "event_id"
    t.integer  "person_id"
  end

  create_table "ropecon_applied_position", :id => false, :force => true do |t|
    t.text "category_fk",     :null => false
    t.text "registration_fk", :null => false
  end

  create_table "ropecon_category", :id => false, :force => true do |t|
    t.text "id",     :null => false
    t.text "namefi"
    t.text "nameen"
  end

  create_table "ropecon_contact", :id => false, :force => true do |t|
    t.text "id",       :null => false
    t.text "type"
    t.text "subtype"
    t.text "data"
    t.text "staff_fk"
  end

  create_table "ropecon_group", :id => false, :force => true do |t|
    t.text "id",        :null => false
    t.text "shortname"
    t.text "longname"
    t.text "parent_id"
  end

  create_table "ropecon_item", :id => false, :force => true do |t|
    t.text    "id",             :null => false
    t.text    "namefi"
    t.text    "nameen"
    t.text    "descfi"
    t.text    "descen"
    t.text    "descfitype"
    t.text    "descentype"
    t.text    "status"
    t.integer "year",           :null => false
    t.text    "notes"
    t.text    "coordinator_fk"
    t.boolean "english"
    t.boolean "beginner"
    t.boolean "majorchange"
  end

  create_table "ropecon_item_category", :id => false, :force => true do |t|
    t.text "category_fk", :null => false
    t.text "item_fk",     :null => false
  end

  create_table "ropecon_item_organizer", :id => false, :force => true do |t|
    t.text "staff_fk", :null => false
    t.text "item_fk",  :null => false
  end

  create_table "ropecon_job_category", :id => false, :force => true do |t|
    t.text "id",   :null => false
    t.text "name"
  end

  create_table "ropecon_job_registration", :id => false, :force => true do |t|
    t.text     "id",                :null => false
    t.datetime "registration_time"
    t.text     "first_name"
    t.text     "last_name"
    t.text     "nick_name"
    t.text     "age"
    t.text     "email"
    t.text     "mobile_phone"
    t.integer  "worked_years",      :null => false
    t.text     "additional_info"
    t.integer  "status",            :null => false
    t.datetime "confirmation_time"
  end

  create_table "ropecon_place", :id => false, :force => true do |t|
    t.text "id",     :null => false
    t.text "namefi"
    t.text "nameen"
  end

  create_table "ropecon_previous_position", :id => false, :force => true do |t|
    t.text "category_fk",     :null => false
    t.text "registration_fk", :null => false
  end

  create_table "ropecon_previous_special_job", :id => false, :force => true do |t|
    t.text "id",              :null => false
    t.text "jobtitle"
    t.text "registration_fk"
  end

  create_table "ropecon_role", :id => false, :force => true do |t|
    t.text    "id",          :null => false
    t.integer "year",        :null => false
    t.text    "description"
    t.text    "staff_fk"
  end

  create_table "ropecon_role_group", :id => false, :force => true do |t|
    t.text "groupid", :null => false
    t.text "roleid",  :null => false
  end

  create_table "ropecon_staff", :id => false, :force => true do |t|
    t.text "id",        :null => false
    t.text "username"
    t.text "firstname"
    t.text "lastname"
    t.text "nickname"
    t.text "street"
    t.text "zipcode"
    t.text "city"
    t.text "country"
    t.text "notes"
    t.text "password"
  end

  create_table "ropecon_timeitem", :id => false, :force => true do |t|
    t.text     "id",        :null => false
    t.text     "descfi"
    t.text     "descen"
    t.datetime "startdate"
    t.datetime "enddate"
    t.text     "place_fk"
    t.text     "item_fk"
  end

  create_table "statusnames", :primary_key => "status", :force => true do |t|
    t.text    "name"
    t.boolean "persongroup", :default => false
    t.boolean "program",     :default => false
    t.boolean "orders",      :default => false
    t.boolean "organizer",   :default => false
  end

end
