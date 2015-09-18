# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140908202929) do

  create_table "action_point_users", force: true do |t|
    t.integer  "user_id"
    t.string   "action"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "actionable_type"
    t.integer  "actionable_id"
  end

  add_index "action_point_users", ["user_id", "action"], name: "index_action_point_users_on_user_id_and_action", using: :btree

  create_table "activity_logs", force: true do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.text     "title"
    t.string   "activity_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "anonymous"
    t.integer  "favorite_user_id"
  end

  add_index "activity_logs", ["anonymous"], name: "index_activity_logs_on_anonymous", using: :btree
  add_index "activity_logs", ["favorite_user_id"], name: "index_activity_logs_on_favorite_user_id", using: :btree
  add_index "activity_logs", ["user_id", "activity_id", "activity_type"], name: "index_activity_logs_on_user_id_and_activity_id_and_activity_type", using: :btree

  create_table "answers", force: true do |t|
    t.integer  "question_answer_id"
    t.integer  "user_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["question_answer_id"], name: "index_answers_on_question_answer_id", using: :btree
  add_index "answers", ["question_id"], name: "index_answers_on_question_id", using: :btree
  add_index "answers", ["user_id"], name: "index_answers_on_user_id", using: :btree

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: true do |t|
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "parent_id"
    t.text     "content"
    t.integer  "comments_count"
    t.integer  "helpfuls_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "anonymous"
    t.boolean  "deleted"
    t.boolean  "locked"
    t.datetime "last_interaction_at"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "luvs_count"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", length: {"commentable_type"=>15}, using: :btree
  add_index "comments", ["deleted"], name: "index_comments_on_deleted", using: :btree
  add_index "comments", ["parent_id"], name: "index_comments_on_parent_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "conditions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
    t.boolean  "suggested"
    t.string   "slug"
  end

  add_index "conditions", ["slug"], name: "index_conditions_on_slug", using: :btree

  create_table "conditions_doctor_reviews", id: false, force: true do |t|
    t.integer "condition_id"
    t.integer "doctor_review_id"
  end

  add_index "conditions_doctor_reviews", ["condition_id"], name: "index_conditions_doctor_reviews_on_condition_id", using: :btree
  add_index "conditions_doctor_reviews", ["doctor_review_id"], name: "index_conditions_doctor_reviews_on_doctor_review_id", using: :btree

  create_table "conditions_posts", id: false, force: true do |t|
    t.integer "condition_id"
    t.integer "post_id"
  end

  add_index "conditions_posts", ["condition_id"], name: "index_conditions_posts_on_condition_id", using: :btree
  add_index "conditions_posts", ["post_id"], name: "index_conditions_posts_on_post_id", using: :btree

  create_table "conditions_treatment_reviews", id: false, force: true do |t|
    t.integer "condition_id"
    t.integer "treatment_review_id"
  end

  add_index "conditions_treatment_reviews", ["condition_id"], name: "index_conditions_treatment_reviews_on_condition_id", using: :btree
  add_index "conditions_treatment_reviews", ["treatment_review_id"], name: "index_conditions_treatment_reviews_on_treatment_review_id", using: :btree

  create_table "conditions_treatment_summaries", id: false, force: true do |t|
    t.integer "condition_id"
    t.integer "treatment_summary_id"
  end

  add_index "conditions_treatment_summaries", ["condition_id"], name: "cond_id", using: :btree
  add_index "conditions_treatment_summaries", ["treatment_summary_id"], name: "tr_summ_id", using: :btree

  create_table "countries", force: true do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "doctor_reviews", force: true do |t|
    t.integer  "doctor_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "doctor_summaries", force: true do |t|
    t.string   "doctor_name"
    t.string   "reviews_count"
    t.string   "latest_review_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "rating"
  end

  create_table "doctors", force: true do |t|
    t.string   "name"
    t.boolean  "recommended"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "doctor_summary_id"
    t.boolean  "currently_seeing"
    t.date     "started_on"
    t.date     "ended_on"
    t.integer  "country_id"
    t.string   "country_cache"
    t.string   "state"
    t.string   "city"
    t.string   "zipcode"
  end

  add_index "doctors", ["country_id"], name: "index_doctors_on_country_id", using: :btree

  create_table "events", force: true do |t|
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "date"
  end

  create_table "helpfuls", force: true do |t|
    t.integer  "user_id"
    t.integer  "markable_id"
    t.string   "markable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "helpfuls", ["markable_id"], name: "index_helpfuls_on_markable_id", using: :btree
  add_index "helpfuls", ["markable_type"], name: "index_helpfuls_on_markable_type", length: {"markable_type"=>15}, using: :btree
  add_index "helpfuls", ["user_id"], name: "index_helpfuls_on_user_id", using: :btree

  create_table "lab_logs", force: true do |t|
    t.integer  "lab_id"
    t.date     "date"
    t.float    "current_value"
    t.string   "unit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lab_summaries", force: true do |t|
    t.string   "lab"
    t.integer  "labs_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "labs", force: true do |t|
    t.string   "name"
    t.float    "current_value"
    t.string   "unit"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lab_summary_id", null: false
  end

  add_index "labs", ["lab_summary_id"], name: "index_labs_on_lab_summary_id", using: :btree

  create_table "luvs", force: true do |t|
    t.integer  "luvable_id"
    t.string   "luvable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "luvs", ["luvable_id"], name: "index_luvs_on_luvable_id", using: :btree
  add_index "luvs", ["user_id"], name: "index_luvs_on_user_id", using: :btree

  create_table "messages", force: true do |t|
    t.integer  "old_id"
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.integer  "reply_to_message_id"
    t.string   "subject"
    t.text     "content"
    t.boolean  "deleted_by_sender"
    t.boolean  "deleted_by_recipient"
    t.boolean  "is_read"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "email_delivered",      default: false
  end

  add_index "messages", ["deleted_by_recipient"], name: "index_messages_on_deleted_by_recipient", using: :btree
  add_index "messages", ["deleted_by_sender"], name: "index_messages_on_deleted_by_sender", using: :btree
  add_index "messages", ["from_user_id"], name: "index_messages_on_from_user_id", using: :btree
  add_index "messages", ["is_read"], name: "index_messages_on_is_read", using: :btree
  add_index "messages", ["reply_to_message_id"], name: "index_messages_on_reply_to_message_id", using: :btree
  add_index "messages", ["to_user_id"], name: "index_messages_on_to_user_id", using: :btree

  create_table "meta_tags", force: true do |t|
    t.string   "url"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "noindex_rules", force: true do |t|
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", force: true do |t|
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.string   "notification_type"
    t.text     "content"
    t.boolean  "is_read"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comment_id"
  end

  add_index "notifications", ["from_user_id"], name: "index_notifications_on_from_user_id", using: :btree
  add_index "notifications", ["is_read"], name: "index_notifications_on_is_read", using: :btree
  add_index "notifications", ["notifiable_id"], name: "index_notifications_on_notifiable_id", using: :btree
  add_index "notifications", ["notifiable_type"], name: "index_notifications_on_notifiable_type", length: {"notifiable_type"=>15}, using: :btree
  add_index "notifications", ["notification_type"], name: "index_notifications_on_notification_type", length: {"notification_type"=>15}, using: :btree
  add_index "notifications", ["to_user_id"], name: "index_notifications_on_to_user_id", using: :btree

  create_table "patient_matches", force: true do |t|
    t.integer  "score"
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "patient_matches", ["from_user_id"], name: "index_patient_matches_on_from_user_id", using: :btree
  add_index "patient_matches", ["to_user_id"], name: "index_patient_matches_on_to_user_id", using: :btree

  create_table "photos", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.text     "description"
    t.integer  "post_id"
    t.integer  "comments_count"
    t.string   "type"
    t.integer  "crop_x"
    t.integer  "crop_y"
    t.integer  "crop_w"
    t.integer  "crop_h"
    t.boolean  "attachment_processing"
    t.string   "title"
  end

  add_index "photos", ["post_id"], name: "index_photos_on_post_id", using: :btree
  add_index "photos", ["user_id"], name: "index_photos_on_user_id", using: :btree

  create_table "post_categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "posts_count"
  end

  create_table "post_followers", force: true do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_followers", ["post_id"], name: "index_post_followers_on_post_id", using: :btree
  add_index "post_followers", ["user_id"], name: "index_post_followers_on_user_id", using: :btree

  create_table "posts", force: true do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "user_id"
    t.integer  "helpfuls_count"
    t.integer  "comments_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "anonymous"
    t.integer  "post_category_id"
    t.integer  "interactions_count"
    t.datetime "last_interaction_at"
    t.integer  "views_count"
    t.boolean  "deleted"
    t.boolean  "locked"
    t.integer  "treatment_review_id"
    t.string   "type",                     default: "Post"
    t.integer  "treatment_level"
    t.boolean  "hide_for_feed",            default: false
    t.boolean  "all_conditions",           default: false
    t.integer  "luvs_count"
    t.datetime "deleted_at"
    t.integer  "last_interaction_user_id"
    t.integer  "doctor_review_id"
    t.boolean  "tracking_update",          default: false
    t.integer  "flags",                    default: 0,      null: false
    t.integer  "activity_post_id"
    t.integer  "comment_id"
  end

  add_index "posts", ["activity_post_id"], name: "index_posts_on_activity_post_id", using: :btree
  add_index "posts", ["anonymous"], name: "index_posts_on_anonymous", using: :btree
  add_index "posts", ["comment_id"], name: "index_posts_on_comment_id", using: :btree
  add_index "posts", ["doctor_review_id"], name: "index_posts_on_doctor_review_id", using: :btree
  add_index "posts", ["hide_for_feed"], name: "index_posts_on_hide_for_feed", using: :btree
  add_index "posts", ["last_interaction_user_id"], name: "index_posts_on_last_interaction_user_id", using: :btree
  add_index "posts", ["post_category_id"], name: "index_posts_on_post_category_id", using: :btree
  add_index "posts", ["tracking_update"], name: "index_posts_on_tracking_update", using: :btree
  add_index "posts", ["treatment_review_id"], name: "index_posts_on_treatment_review_id", using: :btree
  add_index "posts", ["type"], name: "index_posts_on_type", using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "question_answers", force: true do |t|
    t.text     "text"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_answers", ["question_id"], name: "index_question_answers_on_question_id", using: :btree

  create_table "question_categories", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_categories_users", force: true do |t|
    t.integer "question_category_id"
    t.integer "user_id"
  end

  add_index "question_categories_users", ["question_category_id"], name: "index_question_categories_users_on_question_category_id", using: :btree
  add_index "question_categories_users", ["user_id"], name: "index_question_categories_users_on_user_id", using: :btree

  create_table "questions", force: true do |t|
    t.text     "text"
    t.integer  "question_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "multiple_answers",     default: false
  end

  create_table "rails_admin_histories", force: true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories", using: :btree

  create_table "redirects", force: true do |t|
    t.string   "from"
    t.string   "to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "referrals", force: true do |t|
    t.text     "link"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", force: true do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "sub_categories", force: true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "symptom_logs", force: true do |t|
    t.integer  "symptom_id"
    t.integer  "user_id"
    t.datetime "date"
    t.integer  "numeric_level"
    t.integer  "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "symptom_logs", ["symptom_id"], name: "index_symptom_logs_on_symptom_id", using: :btree
  add_index "symptom_logs", ["user_id"], name: "index_symptom_logs_on_user_id", using: :btree

  create_table "symptom_summaries", force: true do |t|
    t.string   "symptom_name"
    t.float    "average_level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "symptoms_count",  default: 0
    t.integer  "sub_category_id"
  end

  create_table "symptom_summary_conditions", force: true do |t|
    t.string   "symptom"
    t.integer  "condition_id"
    t.integer  "symptoms_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "symptoms", force: true do |t|
    t.string   "symptom"
    t.string   "level"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_public"
    t.date     "started_on"
    t.date     "ended_on"
    t.string   "period"
    t.integer  "symptom_summary_id"
    t.integer  "numeric_level"
    t.boolean  "notify",                    default: true
    t.integer  "most_helpful_treatment_id"
    t.datetime "force_version_timestamp"
    t.integer  "rank"
  end

  add_index "symptoms", ["user_id"], name: "index_symptoms_on_user_id", using: :btree

  create_table "system_settings", force: true do |t|
    t.string   "name"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "table_indexes_ones", force: true do |t|
  end

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "taggings_tid_ttype_context", using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  create_table "treatment_logs", force: true do |t|
    t.integer  "treatment_id"
    t.integer  "user_id"
    t.date     "date"
    t.integer  "numeric_level"
    t.boolean  "currently_taking"
    t.boolean  "take_today",       default: false
    t.string   "current_dose",     default: ""
    t.integer  "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "level",            default: ""
  end

  add_index "treatment_logs", ["treatment_id"], name: "index_treatment_logs_on_treatment_id", using: :btree
  add_index "treatment_logs", ["user_id"], name: "index_treatment_logs_on_user_id", using: :btree

  create_table "treatment_reviews", force: true do |t|
    t.integer  "treatment_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "treatment_reviews", ["treatment_id"], name: "index_treatment_reviews_on_treatment_id", using: :btree

  create_table "treatment_summaries", force: true do |t|
    t.string   "treatment_name"
    t.integer  "reviews_count"
    t.integer  "latest_review_id"
    t.decimal  "review_average",   precision: 8, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "product_search",                           default: false
  end

  add_index "treatment_summaries", ["latest_review_id"], name: "index_treatment_summaries_on_latest_review_id", using: :btree

  create_table "treatment_summary_redirects", force: true do |t|
    t.integer  "treatment_summary_id"
    t.string   "old_link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "treatments", force: true do |t|
    t.string   "treatment"
    t.date     "started_on"
    t.date     "ended_on"
    t.integer  "user_id"
    t.string   "result_level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_public"
    t.string   "level",                default: ""
    t.string   "period"
    t.integer  "condition_id"
    t.integer  "numeric_level"
    t.integer  "treatment_summary_id"
    t.string   "treatment_type"
    t.boolean  "currently_taking",     default: false
    t.string   "current_dose",         default: ""
    t.datetime "last_taken_at"
    t.integer  "rank"
    t.boolean  "take_today",           default: false
  end

  add_index "treatments", ["condition_id", "treatment_summary_id"], name: "index_treatments_on_condition_id_and_treatment_summary_id", using: :btree
  add_index "treatments", ["user_id"], name: "index_treatments_on_user_id", using: :btree

  create_table "user_conditions", force: true do |t|
    t.integer  "user_id"
    t.integer  "condition_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_public"
    t.date     "started_on"
  end

  add_index "user_conditions", ["condition_id"], name: "index_user_conditions_on_condition_id", using: :btree
  add_index "user_conditions", ["user_id"], name: "index_user_conditions_on_user_id", using: :btree

  create_table "user_followers", force: true do |t|
    t.integer  "followed_user_id"
    t.integer  "following_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_followers", ["followed_user_id"], name: "index_user_followers_on_followed_user_id", using: :btree
  add_index "user_followers", ["following_user_id"], name: "index_user_followers_on_following_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username"
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                           default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.string   "token_secret"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "main_condition_id"
    t.date     "birth_date"
    t.string   "gender"
    t.string   "location"
    t.text     "bio"
    t.integer  "profile_photo_id"
    t.boolean  "basic_info_step"
    t.boolean  "main_condition_step"
    t.boolean  "medical_info_step"
    t.boolean  "finished_profile"
    t.integer  "old_id"
    t.boolean  "active"
    t.string   "role"
    t.integer  "posts_count"
    t.boolean  "deleted"
    t.boolean  "profile_is_public"
    t.boolean  "photo_is_public"
    t.boolean  "age_is_public"
    t.boolean  "gender_is_public"
    t.boolean  "bio_is_public"
    t.boolean  "main_condition_is_public"
    t.boolean  "followed_users_is_public"
    t.boolean  "following_users_is_public"
    t.text     "banned_reason"
    t.boolean  "full_banned"
    t.boolean  "post_banned"
    t.boolean  "login_banned"
    t.boolean  "registration_banned"
    t.string   "full_name"
    t.string   "user_type"
    t.boolean  "gets_email_for_private_message",          default: true
    t.boolean  "gets_email_for_follower",                 default: true
    t.boolean  "gets_email_for_helpful",                  default: true
    t.boolean  "gets_email_when_mentioned",               default: true
    t.boolean  "gets_email_when_reply",                   default: true
    t.boolean  "gets_email_when_comment",                 default: true
    t.boolean  "gets_email_when_luv",                     default: true
    t.boolean  "gets_email_when_subscribed",              default: true
    t.integer  "country_id"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.boolean  "is_admin"
    t.string   "authentication_token"
    t.datetime "patient_matches_updated_at"
    t.boolean  "gets_email_when_luv_post"
    t.datetime "main_condition_diagnosed_at"
    t.boolean  "main_condition_not_officially_diagnosed"
    t.boolean  "gets_email_when_comment_after",           default: true
    t.boolean  "popular_symptoms_show",                   default: true
    t.float    "latitude"
    t.float    "longitude"
    t.string   "country_cache"
    t.boolean  "my_health_step"
    t.integer  "privacy",                                 default: 1
    t.integer  "tracking_email",                          default: 1
    t.boolean  "update_treatment_logs",                   default: false
    t.boolean  "email_digest_when_comment_after",         default: false
    t.boolean  "email_digest_when_luv",                   default: false
    t.boolean  "email_digest_when_luv_post",              default: false
    t.boolean  "email_digest_when_subscribed",            default: false
    t.boolean  "email_digest_for_private_message",        default: false
    t.boolean  "email_digest_for_follower",               default: false
    t.boolean  "email_digest_for_helpful",                default: false
    t.boolean  "email_digest_when_mentioned",             default: false
    t.boolean  "email_digest_when_reply",                 default: false
    t.boolean  "email_digest_when_comment",               default: false
    t.integer  "flags",                                   default: 0,     null: false
  end

  add_index "users", ["main_condition_id"], name: "index_users_on_main_condition_id", using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "well_being_logs", force: true do |t|
    t.integer  "well_being_id"
    t.datetime "date"
    t.integer  "numeric_level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "well_being_logs", ["well_being_id"], name: "index_well_being_logs_on_well_being_id", using: :btree

  create_table "well_beings", force: true do |t|
    t.integer  "user_id"
    t.integer  "numeric_level"
    t.datetime "force_version_timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
