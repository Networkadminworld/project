class CreateCountsStores < ActiveRecord::Migration
    create_table "counts_stores", force: true do |t|

    t.integer  "question_id", :null =>false
    t.string   "vrtype", :null => false
    t.integer  "norm_date", :null => false
    t.string   "country"
    t.hstore   "counts_key", :null => false, :default => 'tkc=>0,am17=>0,af17=>0,am25=>0,af25=>0,am30=>0,af30=>0,am35=>0,af35=>0,am40=>0,af40=>0,am45=>0,af45=>0,am50=>0,af50=>0,am00=>0,af00=>0,m=>0,f=>0,mail=>0,call=>0,sms=>0,embed=>0,qr=>0,fb=>0,tw=>0,lk=>0'
    t.datetime "created_at"
    t.datetime "updated_at"

  end

  add_index "counts_stores", ["counts_key"], name: "index_counts_stores_on_counts_key", using: :gin
end