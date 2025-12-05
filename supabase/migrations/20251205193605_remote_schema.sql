create extension if not exists "http" with schema "public" version '1.6';

create extension if not exists "pg_net" with schema "public" version '0.14.0';

create type "public"."announcement_audience" as enum ('all', 'customer', 'provider', 'business', 'staff');

create type "public"."announcement_type" as enum ('general', 'promotional', 'maintenance', 'feature', 'alert', 'news', 'update');

create type "public"."background_check_status" as enum ('under_review', 'pending', 'approved', 'rejected', 'expired');

create type "public"."booking_status" as enum ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show', 'declined');

create type "public"."business_document_status" as enum ('pending', 'verified', 'rejected', 'under_review');

create type "public"."business_document_type" as enum ('drivers_license', 'proof_of_address', 'liability_insurance', 'professional_license', 'professional_certificate', 'business_license');

create type "public"."business_payment_transaction_type" as enum ('initial_booking', 'additional_service');

create type "public"."business_type" as enum ('independent', 'small_business', 'franchise', 'enterprise', 'other');

create type "public"."customer_location_type" as enum ('Home', 'Condo', 'Hotel', 'Other', 'Null');

create type "public"."delivery_type" as enum ('business_location', 'customer_location', 'virtual', 'both_locations');

create type "public"."mfa_method_type" as enum ('totp', 'sms', 'email', 'backup');

create type "public"."mfa_status_type" as enum ('pending', 'active', 'disabled', 'locked');

create type "public"."payment_status" as enum ('pending', 'partial', 'paid', 'refunded', 'failed');

create type "public"."promotion_savings_type" as enum ('percentage_off', 'fixed_amount');

create type "public"."provider_role" as enum ('provider', 'owner', 'dispatcher');

create type "public"."provider_verification_status" as enum ('pending', 'documents_submitted', 'under_review', 'approved', 'rejected');

create type "public"."service_category_types" as enum ('beauty', 'fitness', 'therapy', 'healthcare');

create type "public"."service_subcategory_types" as enum ('hair_and_makeup', 'spray_tan', 'esthetician', 'massage_therapy', 'iv_therapy', 'physical_therapy', 'nurse_practitioner', 'physician', 'chiropractor', 'yoga_instructor', 'pilates_instructor', 'personal_trainer', 'injectables', 'health_coach');

create type "public"."status" as enum ('pending', 'completed', 'failed', 'cancelled');

create type "public"."transaction_status" as enum ('pending', 'completed', 'failed', 'cancelled');

create type "public"."transaction_type" as enum ('booking_payment', 'plarform_fee', 'provider_payout', 'refund', 'adjustment', 'tip');

create type "public"."user_role" as enum ('admin', 'manager', 'support', 'analyst');

create type "public"."user_role_type" as enum ('admin', 'owner', 'dispatcher', 'provider', 'customer');

create type "public"."verification_status" as enum ('pending', 'approved', 'rejected', 'suspended');

create table "public"."admin_users" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "email" character varying(255) not null,
    "permissions" jsonb default '[]'::jsonb,
    "is_active" boolean default true,
    "created_at" timestamp without time zone default now(),
    "image_url" text,
    "first_name" text,
    "last_name" text,
    "role" user_role not null,
    "notification_email" text,
    "notification_phone" text
);


create table "public"."announcements" (
    "id" uuid not null default gen_random_uuid(),
    "title" text not null,
    "content" text not null,
    "is_active" boolean default true,
    "created_at" timestamp without time zone default now(),
    "start_date" date,
    "end_date" date,
    "announcement_audience" announcement_audience,
    "announcement_type" announcement_type
);


create table "public"."booking_addons" (
    "id" uuid not null default gen_random_uuid(),
    "booking_id" uuid not null,
    "addon_id" uuid not null,
    "added_at" timestamp without time zone default now()
);


create table "public"."booking_changes" (
    "id" uuid not null default gen_random_uuid(),
    "booking_id" uuid not null,
    "change_type" character varying(50) not null,
    "old_value" jsonb,
    "new_value" jsonb,
    "additional_cost" numeric(10,2) default 0,
    "refund_amount" numeric(10,2) default 0,
    "changed_by" uuid not null,
    "change_reason" text,
    "stripe_charge_id" character varying(255),
    "stripe_refund_id" character varying(255),
    "created_at" timestamp without time zone default now()
);


create table "public"."bookings" (
    "id" uuid not null default gen_random_uuid(),
    "customer_id" uuid not null,
    "provider_id" uuid,
    "service_id" uuid not null,
    "booking_date" date not null,
    "start_time" time without time zone not null,
    "total_amount" numeric not null,
    "created_at" timestamp with time zone default now(),
    "service_fee" numeric not null default 0,
    "service_fee_charged" boolean default false,
    "service_fee_charged_at" timestamp with time zone,
    "remaining_balance" numeric not null default 0,
    "remaining_balance_charged" boolean default false,
    "remaining_balance_charged_at" timestamp with time zone,
    "cancellation_fee" numeric default 0,
    "refund_amount" numeric default 0,
    "cancelled_at" timestamp with time zone,
    "cancelled_by" uuid,
    "cancellation_reason" text,
    "guest_name" text,
    "guest_email" text,
    "guest_phone" text,
    "customer_location_id" uuid,
    "business_location_id" uuid,
    "delivery_type" delivery_type default 'business_location'::delivery_type,
    "payment_status" payment_status default 'pending'::payment_status,
    "booking_status" booking_status default 'pending'::booking_status,
    "admin_notes" text,
    "tip_eligible" boolean default false,
    "tip_amount" numeric default 0,
    "tip_status" text default 'none'::text,
    "tip_requested_at" timestamp with time zone,
    "tip_deadline" timestamp with time zone,
    "booking_reference" text,
    "business_id" uuid not null,
    "decline_reason" text,
    "rescheduled_at" timestamp with time zone,
    "rescheduled_by" uuid,
    "reschedule_reason" text,
    "original_booking_date" date,
    "original_start_time" time without time zone,
    "reschedule_count" integer not null default 0,
    "stripe_checkout_session_id" text,
    "special_instructions" text,
    "stripe_service_amount_payment_intent_id" text
);


create table "public"."business_addons" (
    "id" uuid not null default gen_random_uuid(),
    "business_id" uuid not null,
    "addon_id" uuid not null,
    "custom_price" numeric(10,2),
    "is_available" boolean default true,
    "created_at" timestamp without time zone default now()
);


create table "public"."business_annual_tax_tracking" (
    "id" uuid not null default gen_random_uuid(),
    "business_id" uuid not null,
    "tax_year" integer not null,
    "total_payments_received" numeric(12,2) default 0,
    "payment_count" integer default 0,
    "first_payment_date" date,
    "last_payment_date" date,
    "requires_1099" boolean default false,
    "threshold_reached_date" date,
    "stripe_tax_form_id" text,
    "tax_form_generated" boolean default false,
    "tax_form_generated_date" timestamp with time zone,
    "tax_form_sent" boolean default false,
    "tax_form_sent_date" timestamp with time zone,
    "tax_form_status" character varying(20) default 'pending'::character varying,
    "compliance_status" character varying(20) default 'pending'::character varying,
    "compliance_notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."business_documents" (
    "id" uuid not null default gen_random_uuid(),
    "document_type" business_document_type not null,
    "document_name" character varying(255) not null,
    "file_url" text not null,
    "file_size_bytes" integer,
    "verified_by" uuid,
    "verified_at" timestamp without time zone,
    "rejection_reason" text,
    "expiry_date" date,
    "created_at" timestamp without time zone default now(),
    "verification_status" business_document_status,
    "business_id" uuid not null
);


create table "public"."business_locations" (
    "id" uuid not null default gen_random_uuid(),
    "business_id" uuid not null,
    "location_name" character varying(255),
    "address_line1" character varying(255),
    "address_line2" character varying(255),
    "city" character varying(100),
    "state" character varying(100),
    "postal_code" character varying(20),
    "country" character varying(100),
    "latitude" double precision,
    "longitude" double precision,
    "is_active" boolean default true,
    "created_at" timestamp without time zone default now(),
    "is_primary" boolean,
    "offers_mobile_services" boolean,
    "mobile_service_radius" integer
);


create table "public"."business_manual_bank_accounts" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "business_id" uuid,
    "account_name" text not null,
    "account_type" text not null,
    "account_number" text not null,
    "routing_number" text not null,
    "bank_name" text not null,
    "is_verified" boolean default false,
    "is_default" boolean default false,
    "stripe_account_id" text,
    "verification_status" text default 'pending'::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."business_payment_transactions" (
    "id" uuid not null default gen_random_uuid(),
    "booking_id" uuid not null,
    "business_id" uuid not null,
    "payment_date" date not null,
    "gross_payment_amount" numeric(10,2) not null,
    "platform_fee" numeric(10,2) not null default 0,
    "net_payment_amount" numeric(10,2) not null,
    "tax_year" integer not null,
    "stripe_transfer_id" text,
    "stripe_payment_intent_id" text,
    "stripe_connect_account_id" text,
    "stripe_tax_transaction_id" text,
    "stripe_tax_reported" boolean default false,
    "stripe_tax_report_date" timestamp with time zone,
    "stripe_tax_report_error" text,
    "transaction_description" text default 'Platform service payment'::text,
    "booking_reference" text,
    "created_at" timestamp with time zone default now(),
    "transaction_type" business_payment_transaction_type not null default 'initial_booking'::business_payment_transaction_type
);


create table "public"."business_profiles" (
    "id" uuid not null default gen_random_uuid(),
    "business_name" text not null,
    "contact_email" text,
    "phone" text,
    "verification_status" verification_status default 'pending'::verification_status,
    "stripe_account_id" text,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "image_url" text,
    "website_url" text,
    "logo_url" text,
    "cover_image_url" text,
    "business_hours" jsonb default '{}'::jsonb,
    "social_media" jsonb default '{}'::jsonb,
    "verification_notes" text,
    "business_type" business_type not null,
    "service_categories" service_category_types[],
    "service_subcategories" service_subcategory_types[],
    "setup_completed" boolean,
    "setup_step" numeric,
    "is_featured" boolean,
    "identity_verified" boolean default false,
    "identity_verified_at" timestamp with time zone,
    "bank_connected" boolean default false,
    "bank_connected_at" timestamp with time zone,
    "application_submitted_at" timestamp with time zone,
    "approved_at" timestamp with time zone,
    "approved_by" uuid,
    "approval_notes" text,
    "business_description" text,
    "identity_verification_session_id" text,
    "identity_verification_status" text,
    "identity_verification_data" jsonb
);


create table "public"."business_service_categories" (
    "id" uuid not null default gen_random_uuid(),
    "business_id" uuid not null,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "category_id" uuid
);


alter table "public"."business_service_categories" enable row level security;

create table "public"."business_service_subcategories" (
    "id" uuid not null default gen_random_uuid(),
    "business_id" uuid not null,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "subcategory_id" uuid,
    "category_id" uuid
);


alter table "public"."business_service_subcategories" enable row level security;

create table "public"."business_services" (
    "id" uuid not null default gen_random_uuid(),
    "business_id" uuid not null,
    "service_id" uuid not null,
    "business_price" numeric(10,2) not null,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "delivery_type" delivery_type,
    "business_duration_minutes" integer
);


create table "public"."business_setup_progress" (
    "id" uuid not null default gen_random_uuid(),
    "business_id" uuid,
    "current_step" integer default 1,
    "total_steps" integer default 8,
    "business_profile_completed" boolean default false,
    "locations_completed" boolean default false,
    "services_pricing_completed" boolean default false,
    "staff_setup_completed" boolean default false,
    "integrations_completed" boolean default false,
    "stripe_connect_completed" boolean default false,
    "subscription_completed" boolean default false,
    "go_live_completed" boolean default false,
    "phase_1_completed" boolean default false,
    "phase_1_completed_at" timestamp with time zone,
    "phase_2_completed" boolean default false,
    "phase_2_completed_at" timestamp with time zone,
    "plaid_connected" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "welcome_completed" boolean default false,
    "welcome_data" jsonb default '{}'::jsonb,
    "business_profile_data" jsonb default '{}'::jsonb,
    "personal_profile_completed" boolean default false,
    "personal_profile_data" jsonb default '{}'::jsonb,
    "business_hours_completed" boolean default false,
    "business_hours_data" jsonb default '{}'::jsonb,
    "banking_payout_completed" boolean default false,
    "banking_payout_data" jsonb default '{}'::jsonb,
    "service_pricing_completed" boolean default false,
    "service_pricing_data" jsonb default '{}'::jsonb,
    "final_review_completed" boolean default false,
    "final_review_data" jsonb default '{}'::jsonb
);


alter table "public"."business_setup_progress" enable row level security;

create table "public"."business_stripe_tax_info" (
    "id" uuid not null default gen_random_uuid(),
    "business_id" uuid not null,
    "legal_business_name" text not null,
    "tax_id" text not null,
    "tax_id_type" character varying(3) not null,
    "tax_address_line1" text not null,
    "tax_address_line2" text,
    "tax_city" text not null,
    "tax_state" character varying(2) not null,
    "tax_postal_code" character varying(10) not null,
    "tax_country" character varying(2) not null default 'US'::character varying,
    "business_entity_type" character varying(50) not null,
    "tax_contact_name" text not null,
    "tax_contact_email" text not null,
    "tax_contact_phone" text,
    "stripe_tax_recipient_id" text,
    "stripe_tax_registered" boolean default false,
    "stripe_tax_registration_date" timestamp with time zone,
    "stripe_tax_registration_error" text,
    "w9_status" character varying(20) default 'not_collected'::character varying,
    "w9_requested_date" timestamp with time zone,
    "w9_received_date" timestamp with time zone,
    "tax_setup_completed" boolean default false,
    "tax_setup_completed_date" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."business_subscriptions" (
    "id" uuid not null default gen_random_uuid(),
    "business_id" uuid not null,
    "device_type" text not null,
    "transaction_data" text,
    "start_date" date not null,
    "end_date" date,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "stripe_subscription_id" text,
    "stripe_customer_id" text,
    "stripe_price_id" text,
    "subscription_status" text
);


create table "public"."business_verifications" (
    "id" uuid not null default gen_random_uuid(),
    "business_id" uuid not null,
    "submitted_at" timestamp without time zone default now(),
    "reviewed_at" timestamp without time zone,
    "reviewed_by" uuid,
    "notes" text,
    "is_verified" boolean
);


create table "public"."contact_submissions" (
    "id" uuid not null default gen_random_uuid(),
    "from_email" text not null,
    "to_email" text not null,
    "subject" text not null,
    "message" text not null,
    "status" text default 'received'::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "responded_at" timestamp with time zone,
    "responded_by" uuid,
    "notes" text,
    "category" text,
    "full_name" text
);


alter table "public"."contact_submissions" enable row level security;

create table "public"."conversation_metadata" (
    "id" uuid not null default gen_random_uuid(),
    "booking_id" uuid not null,
    "twilio_conversation_sid" text not null,
    "created_at" timestamp without time zone default now(),
    "updated_at" timestamp without time zone default now(),
    "last_message_at" timestamp without time zone,
    "participant_count" integer default 2,
    "is_active" boolean default true,
    "conversation_type" text default 'booking_chat'::text,
    "last_message_body" text,
    "last_message_author" text,
    "last_message_author_name" text,
    "last_message_timestamp" timestamp with time zone
);


create table "public"."conversation_participants" (
    "id" uuid not null default gen_random_uuid(),
    "conversation_id" uuid not null,
    "user_id" uuid,
    "user_type" text not null,
    "twilio_participant_sid" text not null,
    "joined_at" timestamp without time zone default now(),
    "left_at" timestamp without time zone,
    "is_active" boolean default true,
    "last_read_at" timestamp without time zone
);


alter table "public"."conversation_participants" enable row level security;

create table "public"."customer_favorite_businesses" (
    "id" uuid not null default gen_random_uuid(),
    "customer_id" uuid not null,
    "business_id" uuid not null,
    "created_at" timestamp with time zone default now()
);


alter table "public"."customer_favorite_businesses" enable row level security;

create table "public"."customer_favorite_providers" (
    "id" uuid not null default gen_random_uuid(),
    "customer_id" uuid not null,
    "provider_id" uuid not null,
    "created_at" timestamp with time zone default now()
);


alter table "public"."customer_favorite_providers" enable row level security;

create table "public"."customer_favorite_services" (
    "id" uuid not null default gen_random_uuid(),
    "customer_id" uuid not null,
    "service_id" uuid not null,
    "created_at" timestamp with time zone default now()
);


create table "public"."customer_locations" (
    "id" uuid not null default gen_random_uuid(),
    "customer_id" uuid not null,
    "location_name" character varying(255) not null,
    "street_address" text not null,
    "unit_number" character varying(50),
    "city" character varying(100) not null,
    "state" character varying(50) not null,
    "zip_code" character varying(10) not null,
    "latitude" numeric(10,8),
    "longitude" numeric(11,8),
    "is_primary" boolean default false,
    "is_active" boolean default true,
    "access_instructions" text,
    "created_at" timestamp without time zone default now(),
    "location_type" customer_location_type not null
);


alter table "public"."customer_locations" enable row level security;

create table "public"."customer_profiles" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "phone" text,
    "email" text,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "first_name" text,
    "last_name" text,
    "date_of_birth" date,
    "image_url" text,
    "bio" text,
    "email_notifications" boolean default true,
    "sms_notifications" boolean default true,
    "push_notifications" boolean default true,
    "marketing_emails" boolean default false,
    "email_verified" boolean default false,
    "phone_verified" boolean default false
);


create table "public"."customer_stripe_profiles" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "stripe_customer_id" text not null,
    "stripe_email" text not null,
    "default_payment_method_id" text,
    "billing_address" jsonb,
    "payment_methods" jsonb default '[]'::jsonb,
    "subscription_status" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."customer_stripe_profiles" enable row level security;

create table "public"."customer_subscriptions" (
    "id" uuid not null default gen_random_uuid(),
    "customer_id" uuid not null,
    "device_type" text not null,
    "transaction_data" text,
    "start_date" date not null,
    "end_date" date,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "stripe_subscription_id" text,
    "stripe_customer_id" text,
    "stripe_price_id" text,
    "subscription_status" text
);


create table "public"."email_logs" (
    "id" uuid not null default gen_random_uuid(),
    "recipient_email" text not null,
    "email_type" text not null,
    "subject" text not null,
    "sent_at" timestamp with time zone not null,
    "business_id" uuid,
    "customer_id" uuid,
    "provider_id" uuid,
    "created_at" timestamp with time zone default now()
);


alter table "public"."email_logs" enable row level security;

create table "public"."financial_transactions" (
    "id" uuid not null default gen_random_uuid(),
    "booking_id" uuid not null,
    "amount" numeric(10,2) not null,
    "currency" character varying(3) default 'USD'::character varying,
    "stripe_transaction_id" character varying(255),
    "payment_method" character varying(50),
    "description" text,
    "metadata" jsonb default '{}'::jsonb,
    "created_at" timestamp without time zone default now(),
    "processed_at" timestamp without time zone,
    "transaction_type" transaction_type,
    "status" status
);


create table "public"."message_analytics" (
    "id" uuid not null default gen_random_uuid(),
    "conversation_id" uuid not null,
    "booking_id" uuid not null,
    "message_count" integer default 0,
    "participant_count" integer default 0,
    "first_message_at" timestamp without time zone,
    "last_message_at" timestamp without time zone,
    "average_response_time_minutes" numeric(10,2),
    "total_conversation_duration_minutes" integer,
    "created_at" timestamp without time zone default now(),
    "updated_at" timestamp without time zone default now()
);


create table "public"."message_notifications" (
    "id" uuid not null default gen_random_uuid(),
    "conversation_id" uuid not null,
    "user_id" uuid not null,
    "message_sid" text not null,
    "is_read" boolean default false,
    "read_at" timestamp without time zone,
    "created_at" timestamp without time zone default now(),
    "notification_type" text default 'message'::text
);


create table "public"."mfa_challenges" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "challenge_id" uuid not null,
    "factor_id" uuid not null,
    "method" mfa_method_type not null,
    "code" text,
    "expires_at" timestamp with time zone not null,
    "verified_at" timestamp with time zone,
    "ip_address" inet,
    "user_agent" text,
    "created_at" timestamp with time zone default now()
);


alter table "public"."mfa_challenges" enable row level security;

create table "public"."mfa_factors" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "factor_id" uuid not null,
    "method" mfa_method_type not null,
    "friendly_name" text,
    "secret" text,
    "backup_codes" text[],
    "is_primary" boolean default false,
    "is_verified" boolean default false,
    "verification_attempts" integer default 0,
    "max_attempts" integer default 5,
    "locked_until" timestamp with time zone,
    "last_used_at" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."mfa_factors" enable row level security;

create table "public"."mfa_sessions" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "session_id" uuid not null,
    "factor_id" uuid not null,
    "mfa_completed_at" timestamp with time zone not null,
    "expires_at" timestamp with time zone not null,
    "ip_address" inet,
    "user_agent" text,
    "created_at" timestamp with time zone default now()
);


alter table "public"."mfa_sessions" enable row level security;

create table "public"."mfa_settings" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "mfa_enabled" boolean default false,
    "mfa_required" boolean default true,
    "remember_device_days" integer default 30,
    "backup_codes_enabled" boolean default true,
    "backup_codes_count" integer default 10,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."mfa_settings" enable row level security;

create table "public"."newsletter_subscribers" (
    "id" uuid not null default gen_random_uuid(),
    "email" text not null,
    "subscribed_at" timestamp with time zone not null default now(),
    "unsubscribed_at" timestamp with time zone,
    "source" text default 'marketing_landing'::text,
    "status" text not null default 'active'::text,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
);


alter table "public"."newsletter_subscribers" enable row level security;

create table "public"."notification_logs" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "recipient_email" text,
    "recipient_phone" text,
    "notification_type" text not null,
    "channel" text not null,
    "status" text not null default 'pending'::text,
    "resend_id" text,
    "twilio_sid" text,
    "subject" text,
    "body" text,
    "error_message" text,
    "retry_count" integer default 0,
    "metadata" jsonb,
    "sent_at" timestamp with time zone,
    "delivered_at" timestamp with time zone,
    "created_at" timestamp with time zone default now()
);


alter table "public"."notification_logs" enable row level security;

create table "public"."notification_templates" (
    "id" uuid not null default gen_random_uuid(),
    "template_key" text not null,
    "template_name" text not null,
    "description" text,
    "email_subject" text,
    "email_body_html" text,
    "email_body_text" text,
    "sms_body" text,
    "variables" jsonb default '[]'::jsonb,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."notification_templates" enable row level security;

create table "public"."platform_analytics" (
    "id" uuid not null default gen_random_uuid(),
    "date" date not null,
    "total_bookings" integer default 0,
    "completed_bookings" integer default 0,
    "cancelled_bookings" integer default 0,
    "no_show_bookings" integer default 0,
    "gross_revenue" numeric(12,2) default 0,
    "platform_fees" numeric(12,2) default 0,
    "provider_payouts" numeric(12,2) default 0,
    "refunds_issued" numeric(12,2) default 0,
    "new_customers" integer default 0,
    "new_businesses" integer default 0,
    "new_providers" integer default 0,
    "active_customers" integer default 0,
    "active_providers" integer default 0,
    "average_rating" numeric(3,2) default 0,
    "total_reviews" integer default 0,
    "new_tickets" integer default 0,
    "resolved_tickets" integer default 0,
    "average_resolution_hours" numeric(5,2) default 0,
    "created_at" timestamp without time zone default now()
);


create table "public"."platform_annual_tax_summary" (
    "id" uuid not null default gen_random_uuid(),
    "tax_year" integer not null,
    "total_businesses_paid" integer default 0,
    "total_payments_made" numeric(15,2) default 0,
    "businesses_requiring_1099" integer default 0,
    "total_1099_eligible_payments" numeric(15,2) default 0,
    "forms_1099_generated" integer default 0,
    "forms_1099_sent" integer default 0,
    "forms_1099_delivered" integer default 0,
    "irs_filing_completed" boolean default false,
    "irs_filing_completed_date" timestamp with time zone,
    "processing_status" character varying(20) default 'pending'::character varying,
    "processing_notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."promotion_usage" (
    "id" uuid not null default uuid_generate_v4(),
    "promotion_id" uuid not null,
    "booking_id" uuid not null,
    "discount_applied" numeric(10,2) not null,
    "original_amount" numeric(10,2) not null,
    "final_amount" numeric(10,2) not null,
    "created_at" timestamp with time zone default now(),
    "used_at" timestamp with time zone default now()
);


create table "public"."promotions" (
    "id" uuid not null default gen_random_uuid(),
    "title" character varying(255) not null,
    "description" text,
    "start_date" date,
    "end_date" date,
    "is_active" boolean default true,
    "created_at" timestamp without time zone default now(),
    "business_id" uuid,
    "image_url" text,
    "promo_code" text not null,
    "savings_type" promotion_savings_type,
    "savings_amount" numeric,
    "savings_max_amount" numeric,
    "service_id" uuid
);


create table "public"."provider_addons" (
    "id" uuid not null default gen_random_uuid(),
    "provider_id" uuid not null,
    "addon_id" uuid not null,
    "is_active" boolean default true,
    "created_at" timestamp without time zone default now()
);


create table "public"."provider_applications" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "business_id" uuid,
    "application_status" text default 'submitted'::text,
    "review_status" text default 'pending'::text,
    "consents_given" jsonb,
    "submission_metadata" jsonb,
    "submitted_at" timestamp with time zone default now(),
    "reviewed_at" timestamp with time zone,
    "reviewed_by" uuid,
    "approval_notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."provider_availability" (
    "id" uuid not null default gen_random_uuid(),
    "provider_id" uuid,
    "business_id" uuid,
    "schedule_type" text,
    "day_of_week" integer,
    "start_date" date,
    "end_date" date,
    "start_time" time without time zone not null,
    "end_time" time without time zone not null,
    "max_bookings_per_slot" integer default 1,
    "slot_duration_minutes" integer default 60,
    "buffer_time_minutes" integer default 15,
    "is_active" boolean default true,
    "is_blocked" boolean default false,
    "block_reason" text,
    "allowed_services" uuid[],
    "location_type" text default 'both'::text,
    "service_location_id" uuid,
    "override_price" numeric(10,2),
    "notes" text,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."provider_availability" enable row level security;

create table "public"."provider_availability_exceptions" (
    "id" uuid not null default gen_random_uuid(),
    "provider_id" uuid,
    "exception_date" date not null,
    "exception_type" text default 'unavailable'::text,
    "start_time" time without time zone,
    "end_time" time without time zone,
    "max_bookings" integer,
    "service_location_id" uuid,
    "reason" text not null,
    "notes" text,
    "created_by" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."provider_availability_exceptions" enable row level security;

create table "public"."provider_booking_preferences" (
    "id" uuid not null default gen_random_uuid(),
    "provider_id" uuid,
    "min_advance_hours" integer default 2,
    "max_advance_days" integer default 30,
    "auto_accept_bookings" boolean default false,
    "auto_accept_within_hours" integer default 24,
    "allow_cancellation" boolean default true,
    "cancellation_window_hours" integer default 24,
    "notify_new_booking" boolean default true,
    "notify_cancellation" boolean default true,
    "notify_reminder_hours" integer default 2,
    "prefer_consecutive_bookings" boolean default false,
    "min_break_between_bookings" integer default 15,
    "max_bookings_per_day" integer default 8,
    "updated_at" timestamp with time zone default now()
);


alter table "public"."provider_booking_preferences" enable row level security;

create table "public"."provider_services" (
    "id" uuid not null default gen_random_uuid(),
    "provider_id" uuid not null,
    "service_id" uuid not null,
    "is_active" boolean default true,
    "created_at" timestamp without time zone default now()
);


create table "public"."providers" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "business_id" uuid,
    "location_id" uuid,
    "first_name" text not null,
    "email" text not null,
    "phone" text not null,
    "bio" text,
    "image_url" text,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "last_name" text not null,
    "date_of_birth" date,
    "experience_years" integer,
    "verification_status" provider_verification_status default 'pending'::provider_verification_status,
    "background_check_status" background_check_status default 'under_review'::background_check_status,
    "total_bookings" integer default 0,
    "completed_bookings" integer default 0,
    "average_rating" numeric default 0,
    "total_reviews" integer default 0,
    "provider_role" provider_role,
    "business_managed" boolean not null,
    "notification_email" text,
    "notification_phone" text,
    "cover_image_url" text,
    "identity_verification_status" text default 'pending'::text,
    "active_for_bookings" boolean
);


create table "public"."reviews" (
    "id" uuid not null default gen_random_uuid(),
    "booking_id" uuid not null,
    "overall_rating" integer not null,
    "service_rating" integer,
    "communication_rating" integer,
    "punctuality_rating" integer,
    "review_text" text,
    "is_approved" boolean default false,
    "is_featured" boolean default false,
    "moderated_by" uuid,
    "moderated_at" timestamp with time zone,
    "moderation_notes" text,
    "created_at" timestamp with time zone default now(),
    "business_id" uuid,
    "provider_id" uuid
);


alter table "public"."reviews" enable row level security;

create table "public"."service_addon_eligibility" (
    "id" uuid not null default gen_random_uuid(),
    "service_id" uuid not null,
    "addon_id" uuid not null,
    "is_recommended" boolean default false,
    "created_at" timestamp without time zone default now()
);


create table "public"."service_addons" (
    "id" uuid not null default gen_random_uuid(),
    "name" character varying(255) not null,
    "description" text,
    "image_url" text,
    "is_active" boolean default true,
    "created_at" timestamp without time zone default now(),
    "updated_at" timestamp without time zone default now()
);


create table "public"."service_categories" (
    "id" uuid not null default gen_random_uuid(),
    "description" text,
    "is_active" boolean default true,
    "created_at" timestamp without time zone default now(),
    "image_url" text,
    "sort_order" integer,
    "service_category_type" service_category_types not null
);


create table "public"."service_subcategories" (
    "id" uuid not null default gen_random_uuid(),
    "category_id" uuid not null,
    "description" text,
    "is_active" boolean default true,
    "created_at" timestamp without time zone default now(),
    "image_url" text,
    "service_subcategory_type" service_subcategory_types not null
);


create table "public"."services" (
    "id" uuid not null default gen_random_uuid(),
    "subcategory_id" uuid not null,
    "name" text not null,
    "description" text,
    "min_price" numeric not null,
    "duration_minutes" integer not null,
    "image_url" text,
    "is_active" boolean default true,
    "created_at" timestamp with time zone default now(),
    "is_featured" boolean default false,
    "is_popular" boolean default false
);


create table "public"."stripe_connect_accounts" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "business_id" uuid,
    "account_id" text not null,
    "account_type" text,
    "country" text,
    "default_currency" text,
    "business_type" text,
    "details_submitted" boolean default false,
    "charges_enabled" boolean default false,
    "payouts_enabled" boolean default false,
    "capabilities" jsonb,
    "requirements" jsonb,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."stripe_connect_accounts" enable row level security;

create table "public"."stripe_identity_verifications" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "business_id" uuid,
    "session_id" text not null,
    "status" text,
    "type" text,
    "client_secret" text,
    "verification_report" jsonb,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "verified_at" timestamp with time zone,
    "failed_at" timestamp with time zone
);


alter table "public"."stripe_identity_verifications" enable row level security;

create table "public"."stripe_tax_webhook_events" (
    "id" uuid not null default gen_random_uuid(),
    "business_id" uuid,
    "stripe_event_id" text not null,
    "stripe_event_type" character varying(50) not null,
    "stripe_object_id" text,
    "stripe_object_type" character varying(30),
    "event_data" jsonb,
    "processed" boolean default false,
    "processed_at" timestamp with time zone,
    "processing_error" text,
    "webhook_received_at" timestamp with time zone default now(),
    "api_version" text,
    "created_at" timestamp with time zone default now()
);


create table "public"."system_config" (
    "id" uuid not null default uuid_generate_v4(),
    "config_key" character varying(100) not null,
    "config_value" text,
    "description" text,
    "data_type" character varying(50) default 'string'::character varying,
    "is_public" boolean default false,
    "config_group" text,
    "is_encrypted" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."system_config" enable row level security;

create table "public"."tip_analytics_daily" (
    "id" uuid not null default gen_random_uuid(),
    "date" date not null,
    "total_tips_count" integer default 0,
    "total_tips_amount" numeric(12,2) default 0,
    "average_tip_amount" numeric(8,2) default 0,
    "average_tip_percentage" numeric(5,2) default 0,
    "tips_by_category" jsonb default '{}'::jsonb,
    "unique_tipping_customers" integer default 0,
    "repeat_tippers" integer default 0,
    "tip_conversion_rate" numeric(5,2) default 0,
    "providers_receiving_tips" integer default 0,
    "platform_fee_from_tips" numeric(10,2) default 0,
    "created_at" timestamp without time zone default now()
);


create table "public"."tip_presets" (
    "id" uuid not null default gen_random_uuid(),
    "service_category_id" uuid,
    "preset_type" character varying(20) not null,
    "preset_values" jsonb not null,
    "is_active" boolean default true,
    "default_selection" integer,
    "allow_custom_amount" boolean default true,
    "minimum_tip_amount" numeric(8,2) default 1.00,
    "maximum_tip_amount" numeric(8,2) default 500.00,
    "tip_window_hours" integer default 72,
    "created_at" timestamp without time zone default now(),
    "updated_at" timestamp without time zone default now()
);


create table "public"."tips" (
    "id" uuid not null default gen_random_uuid(),
    "booking_id" uuid not null,
    "customer_id" uuid,
    "provider_id" uuid not null,
    "business_id" uuid not null,
    "tip_amount" numeric not null,
    "tip_percentage" numeric,
    "stripe_payment_intent_id" text,
    "payment_status" text default 'pending'::text,
    "platform_fee_amount" numeric default 0,
    "provider_net_amount" numeric not null,
    "customer_message" text,
    "provider_response" text,
    "provider_responded_at" timestamp with time zone,
    "tip_given_at" timestamp with time zone default now(),
    "payment_processed_at" timestamp with time zone,
    "payout_status" text default 'pending'::text,
    "payout_batch_id" uuid,
    "payout_date" date,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


create table "public"."user_settings" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "theme" text default 'system'::text,
    "language" text default 'en'::text,
    "timezone" text default 'UTC'::text,
    "email_notifications" boolean default true,
    "push_notifications" boolean default true,
    "sound_enabled" boolean default true,
    "auto_logout_minutes" integer default 60,
    "date_format" text default 'MM/DD/YYYY'::text,
    "time_format" text default '12h'::text,
    "items_per_page" integer default 25,
    "sidebar_collapsed" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "sms_notifications" boolean,
    "customer_booking_accepted_email" boolean default true,
    "customer_booking_accepted_sms" boolean default false,
    "customer_booking_completed_email" boolean default true,
    "customer_booking_completed_sms" boolean default false,
    "customer_booking_reminder_email" boolean default true,
    "customer_booking_reminder_sms" boolean default true,
    "customer_welcome_email" boolean default true,
    "provider_new_booking_email" boolean default true,
    "provider_new_booking_sms" boolean default true,
    "provider_booking_cancelled_email" boolean default true,
    "provider_booking_cancelled_sms" boolean default false,
    "provider_booking_rescheduled_email" boolean default true,
    "provider_booking_rescheduled_sms" boolean default false,
    "admin_business_verification_email" boolean default true,
    "admin_business_verification_sms" boolean default false,
    "quiet_hours_enabled" boolean default false,
    "quiet_hours_start" time without time zone,
    "quiet_hours_end" time without time zone,
    "notification_email" text,
    "notification_phone" text,
    "customer_booking_declined_email" boolean default true,
    "customer_booking_declined_sms" boolean default false,
    "customer_booking_no_show_email" boolean default true,
    "customer_booking_no_show_sms" boolean default false
);


alter table "public"."user_settings" enable row level security;

CREATE UNIQUE INDEX admin_users_pkey ON public.admin_users USING btree (id);

CREATE UNIQUE INDEX announcements_pkey ON public.announcements USING btree (id);

CREATE UNIQUE INDEX booking_addons_pkey ON public.booking_addons USING btree (id);

CREATE UNIQUE INDEX booking_changes_pkey ON public.booking_changes USING btree (id);

CREATE UNIQUE INDEX bookings_booking_reference_unique ON public.bookings USING btree (booking_reference);

CREATE UNIQUE INDEX bookings_pkey ON public.bookings USING btree (id);

CREATE UNIQUE INDEX business_addon_pricing_business_id_addon_id_key ON public.business_addons USING btree (business_id, addon_id);

CREATE UNIQUE INDEX business_addon_pricing_pkey ON public.business_addons USING btree (id);

CREATE UNIQUE INDEX business_annual_tax_tracking_business_id_tax_year_key ON public.business_annual_tax_tracking USING btree (business_id, tax_year);

CREATE UNIQUE INDEX business_annual_tax_tracking_pkey ON public.business_annual_tax_tracking USING btree (id);

CREATE UNIQUE INDEX business_locations_pkey ON public.business_locations USING btree (id);

CREATE UNIQUE INDEX business_payment_transactions_pkey ON public.business_payment_transactions USING btree (id);

CREATE UNIQUE INDEX business_profiles_pkey ON public.business_profiles USING btree (id);

CREATE UNIQUE INDEX business_service_categories_pkey ON public.business_service_categories USING btree (id);

CREATE UNIQUE INDEX business_service_subcategories_pkey ON public.business_service_subcategories USING btree (id);

CREATE UNIQUE INDEX business_services_pkey ON public.business_services USING btree (id);

CREATE UNIQUE INDEX business_services_unique ON public.business_services USING btree (business_id, service_id);

CREATE UNIQUE INDEX business_setup_progress_business_id_key ON public.business_setup_progress USING btree (business_id);

CREATE UNIQUE INDEX business_setup_progress_pkey ON public.business_setup_progress USING btree (id);

CREATE UNIQUE INDEX business_stripe_tax_info_business_id_key ON public.business_stripe_tax_info USING btree (business_id);

CREATE UNIQUE INDEX business_stripe_tax_info_pkey ON public.business_stripe_tax_info USING btree (id);

CREATE UNIQUE INDEX business_subscriptions_pkey ON public.business_subscriptions USING btree (id);

CREATE UNIQUE INDEX business_verifications_pkey ON public.business_verifications USING btree (id);

CREATE UNIQUE INDEX contact_submissions_pkey ON public.contact_submissions USING btree (id);

CREATE UNIQUE INDEX conversation_metadata_pkey ON public.conversation_metadata USING btree (id);

CREATE UNIQUE INDEX conversation_metadata_twilio_conversation_sid_key ON public.conversation_metadata USING btree (twilio_conversation_sid);

CREATE UNIQUE INDEX conversation_participants_pkey ON public.conversation_participants USING btree (id);

CREATE UNIQUE INDEX customer_favorite_businesses_customer_id_business_id_key ON public.customer_favorite_businesses USING btree (customer_id, business_id);

CREATE UNIQUE INDEX customer_favorite_businesses_pkey ON public.customer_favorite_businesses USING btree (id);

CREATE UNIQUE INDEX customer_favorite_providers_customer_id_provider_id_key ON public.customer_favorite_providers USING btree (customer_id, provider_id);

CREATE UNIQUE INDEX customer_favorite_providers_pkey ON public.customer_favorite_providers USING btree (id);

CREATE UNIQUE INDEX customer_favorite_services_customer_id_service_id_key ON public.customer_favorite_services USING btree (customer_id, service_id);

CREATE UNIQUE INDEX customer_favorite_services_pkey ON public.customer_favorite_services USING btree (id);

CREATE UNIQUE INDEX customer_locations_pkey ON public.customer_locations USING btree (id);

CREATE UNIQUE INDEX customer_profiles_pkey ON public.customer_profiles USING btree (id);

CREATE UNIQUE INDEX customer_profiles_user_id_key ON public.customer_profiles USING btree (user_id);

CREATE UNIQUE INDEX customer_stripe_profiles_pkey ON public.customer_stripe_profiles USING btree (id);

CREATE UNIQUE INDEX customer_stripe_profiles_stripe_customer_id_key ON public.customer_stripe_profiles USING btree (stripe_customer_id);

CREATE UNIQUE INDEX customer_subscriptions_pkey ON public.customer_subscriptions USING btree (id);

CREATE UNIQUE INDEX email_logs_pkey ON public.email_logs USING btree (id);

CREATE UNIQUE INDEX financial_transactions_pkey ON public.financial_transactions USING btree (id);

CREATE INDEX idx_admin_users_email ON public.admin_users USING btree (email);

CREATE INDEX idx_booking_addons_booking ON public.booking_addons USING btree (booking_id);

CREATE INDEX idx_booking_changes_booking ON public.booking_changes USING btree (booking_id);

CREATE INDEX idx_bookings_booking_date ON public.bookings USING btree (booking_date);

CREATE INDEX idx_bookings_booking_status ON public.bookings USING btree (booking_status);

CREATE INDEX idx_bookings_business_booking_date ON public.bookings USING btree (business_id, booking_date);

CREATE INDEX idx_bookings_business_date ON public.bookings USING btree (business_id, created_at);

CREATE INDEX idx_bookings_business_date_status ON public.bookings USING btree (business_id, booking_date DESC, booking_status);

CREATE INDEX idx_bookings_business_id ON public.bookings USING btree (business_id);

CREATE INDEX idx_bookings_business_status ON public.bookings USING btree (business_id, booking_status);

CREATE INDEX idx_bookings_created_at ON public.bookings USING btree (created_at DESC);

CREATE INDEX idx_bookings_customer_id ON public.bookings USING btree (customer_id);

CREATE INDEX idx_bookings_date ON public.bookings USING btree (booking_date);

CREATE INDEX idx_bookings_payment_status ON public.bookings USING btree (payment_status);

CREATE INDEX idx_bookings_provider_date ON public.bookings USING btree (provider_id, booking_date DESC) WHERE (provider_id IS NOT NULL);

CREATE INDEX idx_bookings_provider_id ON public.bookings USING btree (provider_id);

CREATE INDEX idx_bookings_reschedule_count ON public.bookings USING btree (reschedule_count);

CREATE INDEX idx_bookings_rescheduled_at ON public.bookings USING btree (rescheduled_at);

CREATE INDEX idx_bookings_service_amount_capture ON public.bookings USING btree (stripe_service_amount_payment_intent_id, remaining_balance_charged, booking_date, start_time) WHERE ((stripe_service_amount_payment_intent_id IS NOT NULL) AND (remaining_balance_charged = false) AND (booking_status = 'confirmed'::booking_status));

CREATE INDEX idx_bookings_service_id ON public.bookings USING btree (service_id);

CREATE INDEX idx_bookings_status ON public.bookings USING btree (booking_status);

CREATE INDEX idx_bsc_business_category_active ON public.business_service_categories USING btree (business_id, category_id) WHERE (is_active = true);

CREATE INDEX idx_bss_business_active ON public.business_service_subcategories USING btree (business_id) WHERE (is_active = true);

CREATE INDEX idx_bss_subcategory_business ON public.business_service_subcategories USING btree (subcategory_id, business_id);

CREATE INDEX idx_business_addons_business_addon ON public.business_addons USING btree (business_id, addon_id);

CREATE INDEX idx_business_annual_tax_1099 ON public.business_annual_tax_tracking USING btree (requires_1099, tax_year);

CREATE INDEX idx_business_annual_tax_business ON public.business_annual_tax_tracking USING btree (business_id, tax_year);

CREATE INDEX idx_business_annual_tax_form_status ON public.business_annual_tax_tracking USING btree (tax_form_status, tax_year);

CREATE INDEX idx_business_annual_tax_threshold ON public.business_annual_tax_tracking USING btree (threshold_reached_date);

CREATE INDEX idx_business_documents_business_id ON public.business_documents USING btree (business_id);

CREATE INDEX idx_business_documents_business_id_status ON public.business_documents USING btree (business_id, verification_status);

CREATE INDEX idx_business_documents_document_type ON public.business_documents USING btree (document_type);

CREATE INDEX idx_business_documents_verification_status ON public.business_documents USING btree (verification_status);

CREATE INDEX idx_business_locations_business ON public.business_locations USING btree (business_id, is_active);

CREATE INDEX idx_business_payment_transactions_booking ON public.business_payment_transactions USING btree (booking_id);

CREATE INDEX idx_business_payment_transactions_business ON public.business_payment_transactions USING btree (business_id, tax_year);

CREATE INDEX idx_business_payment_transactions_business_payment_date ON public.business_payment_transactions USING btree (business_id, payment_date DESC);

CREATE INDEX idx_business_payment_transactions_business_tax_year ON public.business_payment_transactions USING btree (business_id, tax_year);

CREATE INDEX idx_business_payment_transactions_date ON public.business_payment_transactions USING btree (payment_date);

CREATE INDEX idx_business_payment_transactions_payment_intent ON public.business_payment_transactions USING btree (stripe_payment_intent_id);

CREATE INDEX idx_business_payment_transactions_reported ON public.business_payment_transactions USING btree (stripe_tax_reported, tax_year);

CREATE INDEX idx_business_payment_transactions_stripe ON public.business_payment_transactions USING btree (stripe_transfer_id, stripe_connect_account_id);

CREATE INDEX idx_business_payment_transactions_transaction_type ON public.business_payment_transactions USING btree (transaction_type);

CREATE INDEX idx_business_payment_transactions_type ON public.business_payment_transactions USING btree (booking_id, transaction_type);

CREATE INDEX idx_business_profiles_created_at ON public.business_profiles USING btree (created_at DESC);

CREATE INDEX idx_business_profiles_description_search ON public.business_profiles USING gin (to_tsvector('english'::regconfig, business_description)) WHERE (business_description IS NOT NULL);

CREATE INDEX idx_business_profiles_identity_session ON public.business_profiles USING btree (identity_verification_session_id);

CREATE INDEX idx_business_profiles_identity_status ON public.business_profiles USING btree (identity_verification_status);

CREATE INDEX idx_business_profiles_is_active ON public.business_profiles USING btree (is_active);

CREATE INDEX idx_business_profiles_name ON public.business_profiles USING btree (business_name);

CREATE INDEX idx_business_profiles_verification_status ON public.business_profiles USING btree (verification_status);

CREATE INDEX idx_business_profiles_verification_status_created ON public.business_profiles USING btree (verification_status, created_at DESC);

CREATE INDEX idx_business_service_categories_active ON public.business_service_categories USING btree (is_active) WHERE (is_active = true);

CREATE INDEX idx_business_service_categories_business_id ON public.business_service_categories USING btree (business_id);

CREATE INDEX idx_business_service_subcategories_active ON public.business_service_subcategories USING btree (is_active) WHERE (is_active = true);

CREATE INDEX idx_business_service_subcategories_business_id ON public.business_service_subcategories USING btree (business_id);

CREATE INDEX idx_business_services_business_id ON public.business_services USING btree (business_id);

CREATE INDEX idx_business_services_business_service ON public.business_services USING btree (business_id, service_id);

CREATE INDEX idx_business_services_is_active ON public.business_services USING btree (is_active);

CREATE INDEX idx_business_services_service_id ON public.business_services USING btree (service_id);

CREATE INDEX idx_business_setup_progress_business_id ON public.business_setup_progress USING btree (business_id);

CREATE INDEX idx_business_stripe_tax_business ON public.business_stripe_tax_info USING btree (business_id);

CREATE INDEX idx_business_stripe_tax_registration ON public.business_stripe_tax_info USING btree (stripe_tax_registered, stripe_tax_recipient_id);

CREATE INDEX idx_business_stripe_tax_w9 ON public.business_stripe_tax_info USING btree (w9_status, w9_requested_date);

CREATE INDEX idx_business_subscriptions_business_id ON public.business_subscriptions USING btree (business_id);

CREATE INDEX idx_business_subscriptions_stripe_subscription_id ON public.business_subscriptions USING btree (stripe_subscription_id);

CREATE INDEX idx_contact_submissions_created_at ON public.contact_submissions USING btree (created_at DESC);

CREATE INDEX idx_contact_submissions_from_email ON public.contact_submissions USING btree (from_email);

CREATE INDEX idx_contact_submissions_status ON public.contact_submissions USING btree (status);

CREATE INDEX idx_conversation_metadata_booking ON public.conversation_metadata USING btree (booking_id) WHERE (is_active = true);

CREATE INDEX idx_conversation_metadata_booking_id ON public.conversation_metadata USING btree (booking_id);

CREATE INDEX idx_conversation_metadata_created_at ON public.conversation_metadata USING btree (created_at);

CREATE INDEX idx_conversation_metadata_last_message ON public.conversation_metadata USING btree (last_message_at DESC NULLS LAST);

CREATE INDEX idx_conversation_metadata_last_message_at ON public.conversation_metadata USING btree (last_message_at);

CREATE INDEX idx_conversation_metadata_twilio_sid ON public.conversation_metadata USING btree (twilio_conversation_sid);

CREATE INDEX idx_conversation_participants_conversation_id ON public.conversation_participants USING btree (conversation_id);

CREATE INDEX idx_conversation_participants_twilio_sid ON public.conversation_participants USING btree (twilio_participant_sid);

CREATE INDEX idx_conversation_participants_user_active ON public.conversation_participants USING btree (user_id, is_active) WHERE (is_active = true);

CREATE INDEX idx_conversation_participants_user_id ON public.conversation_participants USING btree (user_id);

CREATE INDEX idx_conversation_participants_user_type ON public.conversation_participants USING btree (user_type);

CREATE INDEX idx_customer_favorite_businesses_business_id ON public.customer_favorite_businesses USING btree (business_id);

CREATE INDEX idx_customer_favorite_businesses_customer_id ON public.customer_favorite_businesses USING btree (customer_id);

CREATE INDEX idx_customer_favorite_providers_customer_id ON public.customer_favorite_providers USING btree (customer_id);

CREATE INDEX idx_customer_favorite_providers_provider_id ON public.customer_favorite_providers USING btree (provider_id);

CREATE INDEX idx_customer_favorite_services_customer_id ON public.customer_favorite_services USING btree (customer_id);

CREATE INDEX idx_customer_favorite_services_service_id ON public.customer_favorite_services USING btree (service_id);

CREATE INDEX idx_customer_profiles_created_at ON public.customer_profiles USING btree (created_at);

CREATE INDEX idx_customer_profiles_is_active ON public.customer_profiles USING btree (is_active);

CREATE INDEX idx_customer_profiles_user_id ON public.customer_profiles USING btree (user_id);

CREATE INDEX idx_customer_stripe_profiles_email ON public.customer_stripe_profiles USING btree (stripe_email);

CREATE UNIQUE INDEX idx_customer_stripe_profiles_stripe_id ON public.customer_stripe_profiles USING btree (stripe_customer_id);

CREATE INDEX idx_customer_stripe_profiles_user_id ON public.customer_stripe_profiles USING btree (user_id);

CREATE INDEX idx_customer_subscriptions_customer_id ON public.customer_subscriptions USING btree (customer_id);

CREATE INDEX idx_customer_subscriptions_stripe_subscription_id ON public.customer_subscriptions USING btree (stripe_subscription_id);

CREATE INDEX idx_email_logs_business_id ON public.email_logs USING btree (business_id);

CREATE INDEX idx_email_logs_customer_id ON public.email_logs USING btree (customer_id);

CREATE INDEX idx_email_logs_email_type ON public.email_logs USING btree (email_type);

CREATE INDEX idx_email_logs_provider_id ON public.email_logs USING btree (provider_id);

CREATE INDEX idx_financial_transactions_booking ON public.financial_transactions USING btree (booking_id);

CREATE INDEX idx_financial_transactions_booking_id ON public.financial_transactions USING btree (booking_id);

CREATE INDEX idx_financial_transactions_created_at ON public.financial_transactions USING btree (created_at DESC);

CREATE INDEX idx_financial_transactions_status ON public.financial_transactions USING btree (status, created_at);

CREATE INDEX idx_financial_transactions_type ON public.financial_transactions USING btree (transaction_type, created_at);

CREATE INDEX idx_financial_transactions_type_status ON public.financial_transactions USING btree (transaction_type, status);

CREATE INDEX idx_manual_bank_accounts_business_id ON public.business_manual_bank_accounts USING btree (business_id);

CREATE INDEX idx_manual_bank_accounts_is_default ON public.business_manual_bank_accounts USING btree (is_default);

CREATE INDEX idx_manual_bank_accounts_user_id ON public.business_manual_bank_accounts USING btree (user_id);

CREATE INDEX idx_message_analytics_booking_id ON public.message_analytics USING btree (booking_id);

CREATE INDEX idx_message_analytics_conversation_id ON public.message_analytics USING btree (conversation_id);

CREATE INDEX idx_message_analytics_created_at ON public.message_analytics USING btree (created_at);

CREATE INDEX idx_message_notifications_conversation_id ON public.message_notifications USING btree (conversation_id);

CREATE INDEX idx_message_notifications_created_at ON public.message_notifications USING btree (created_at);

CREATE INDEX idx_message_notifications_is_read ON public.message_notifications USING btree (is_read);

CREATE INDEX idx_message_notifications_user_id ON public.message_notifications USING btree (user_id);

CREATE INDEX idx_message_notifications_user_unread ON public.message_notifications USING btree (user_id, conversation_id) WHERE (is_read = false);

CREATE INDEX idx_mfa_challenges_expires_at ON public.mfa_challenges USING btree (expires_at);

CREATE INDEX idx_mfa_challenges_user_id ON public.mfa_challenges USING btree (user_id);

CREATE INDEX idx_mfa_factors_is_primary ON public.mfa_factors USING btree (is_primary) WHERE (is_primary = true);

CREATE INDEX idx_mfa_factors_method ON public.mfa_factors USING btree (method);

CREATE INDEX idx_mfa_factors_user_id ON public.mfa_factors USING btree (user_id);

CREATE INDEX idx_mfa_sessions_session_id ON public.mfa_sessions USING btree (session_id);

CREATE INDEX idx_mfa_sessions_user_id ON public.mfa_sessions USING btree (user_id);

CREATE INDEX idx_mfa_settings_user_id ON public.mfa_settings USING btree (user_id);

CREATE INDEX idx_newsletter_subscribers_email ON public.newsletter_subscribers USING btree (email);

CREATE INDEX idx_newsletter_subscribers_source ON public.newsletter_subscribers USING btree (source);

CREATE INDEX idx_newsletter_subscribers_status ON public.newsletter_subscribers USING btree (status);

CREATE INDEX idx_newsletter_subscribers_subscribed_at ON public.newsletter_subscribers USING btree (subscribed_at DESC);

CREATE INDEX idx_notification_logs_channel ON public.notification_logs USING btree (channel);

CREATE INDEX idx_notification_logs_created_at ON public.notification_logs USING btree (created_at DESC);

CREATE INDEX idx_notification_logs_notification_type ON public.notification_logs USING btree (notification_type);

CREATE INDEX idx_notification_logs_sent_at ON public.notification_logs USING btree (sent_at DESC);

CREATE INDEX idx_notification_logs_status ON public.notification_logs USING btree (status);

CREATE INDEX idx_notification_logs_type_status ON public.notification_logs USING btree (notification_type, status);

CREATE INDEX idx_notification_logs_user_id ON public.notification_logs USING btree (user_id);

CREATE INDEX idx_notification_logs_user_status ON public.notification_logs USING btree (user_id, status);

CREATE INDEX idx_notification_templates_is_active ON public.notification_templates USING btree (is_active);

CREATE INDEX idx_notification_templates_template_key ON public.notification_templates USING btree (template_key);

CREATE INDEX idx_platform_analytics_date ON public.platform_analytics USING btree (date);

CREATE INDEX idx_platform_annual_tax_year ON public.platform_annual_tax_summary USING btree (tax_year);

CREATE INDEX idx_provider_applications_business_id ON public.provider_applications USING btree (business_id);

CREATE INDEX idx_provider_applications_status ON public.provider_applications USING btree (application_status);

CREATE INDEX idx_provider_availability_active ON public.provider_availability USING btree (is_active, is_blocked);

CREATE INDEX idx_provider_availability_business_id ON public.provider_availability USING btree (business_id);

CREATE INDEX idx_provider_availability_date_range ON public.provider_availability USING btree (start_date, end_date);

CREATE INDEX idx_provider_availability_day_of_week ON public.provider_availability USING btree (day_of_week);

CREATE INDEX idx_provider_availability_exceptions_date ON public.provider_availability_exceptions USING btree (exception_date);

CREATE INDEX idx_provider_availability_exceptions_provider_date ON public.provider_availability_exceptions USING btree (provider_id, exception_date);

CREATE INDEX idx_provider_availability_provider_id ON public.provider_availability USING btree (provider_id);

CREATE INDEX idx_provider_booking_preferences_provider_id ON public.provider_booking_preferences USING btree (provider_id);

CREATE INDEX idx_provider_services_provider ON public.provider_services USING btree (provider_id, is_active);

CREATE INDEX idx_provider_subscriptions_provider_id ON public.business_subscriptions USING btree (business_id);

CREATE INDEX idx_providers_business_id ON public.providers USING btree (business_id);

CREATE INDEX idx_providers_created_at ON public.providers USING btree (created_at);

CREATE INDEX idx_providers_is_active ON public.providers USING btree (is_active);

CREATE INDEX idx_providers_location_id ON public.providers USING btree (location_id);

CREATE INDEX idx_providers_user_id ON public.providers USING btree (user_id);

CREATE INDEX idx_providers_verification ON public.providers USING btree (verification_status);

CREATE INDEX idx_reviews_booking_id ON public.reviews USING btree (booking_id);

CREATE INDEX idx_reviews_business_id ON public.reviews USING btree (business_id);

CREATE INDEX idx_reviews_created_at ON public.reviews USING btree (created_at);

CREATE INDEX idx_reviews_is_approved ON public.reviews USING btree (is_approved);

CREATE INDEX idx_reviews_is_featured ON public.reviews USING btree (is_featured);

CREATE INDEX idx_reviews_overall_rating ON public.reviews USING btree (overall_rating);

CREATE INDEX idx_reviews_provider_id ON public.reviews USING btree (provider_id);

CREATE INDEX idx_sae_service_addon ON public.service_addon_eligibility USING btree (service_id, addon_id);

CREATE INDEX idx_service_addon_eligibility_service ON public.service_addon_eligibility USING btree (service_id);

CREATE INDEX idx_service_categories_is_active ON public.service_categories USING btree (is_active);

CREATE INDEX idx_service_subcategories_category_id ON public.service_subcategories USING btree (category_id);

CREATE INDEX idx_service_subcategories_is_active ON public.service_subcategories USING btree (is_active);

CREATE INDEX idx_services_created_at ON public.services USING btree (created_at DESC);

CREATE INDEX idx_services_featured ON public.services USING btree (is_featured) WHERE (is_featured = true);

CREATE INDEX idx_services_is_active ON public.services USING btree (is_active);

CREATE INDEX idx_services_is_featured ON public.services USING btree (is_featured);

CREATE INDEX idx_services_is_popular ON public.services USING btree (is_popular);

CREATE INDEX idx_services_popular ON public.services USING btree (is_popular) WHERE (is_popular = true);

CREATE INDEX idx_services_price ON public.services USING btree (min_price);

CREATE INDEX idx_services_subcategory_active ON public.services USING btree (subcategory_id) WHERE (is_active = true);

CREATE INDEX idx_services_subcategory_id ON public.services USING btree (subcategory_id);

CREATE INDEX idx_stripe_connect_accounts_business_id ON public.stripe_connect_accounts USING btree (business_id);

CREATE INDEX idx_stripe_identity_verifications_business ON public.stripe_identity_verifications USING btree (business_id);

CREATE INDEX idx_stripe_identity_verifications_business_id ON public.stripe_identity_verifications USING btree (business_id);

CREATE INDEX idx_stripe_identity_verifications_session ON public.stripe_identity_verifications USING btree (session_id);

CREATE INDEX idx_stripe_identity_verifications_status ON public.stripe_identity_verifications USING btree (status);

CREATE INDEX idx_stripe_identity_verifications_user ON public.stripe_identity_verifications USING btree (user_id);

CREATE INDEX idx_stripe_tax_webhooks_business ON public.stripe_tax_webhook_events USING btree (business_id);

CREATE INDEX idx_stripe_tax_webhooks_event ON public.stripe_tax_webhook_events USING btree (stripe_event_type, processed);

CREATE INDEX idx_stripe_tax_webhooks_object ON public.stripe_tax_webhook_events USING btree (stripe_object_id, stripe_object_type);

CREATE INDEX idx_tip_analytics_date ON public.tip_analytics_daily USING btree (date);

CREATE INDEX idx_tips_booking_id ON public.tips USING btree (booking_id);

CREATE INDEX idx_tips_business_id ON public.tips USING btree (business_id);

CREATE INDEX idx_tips_customer_id ON public.tips USING btree (customer_id);

CREATE INDEX idx_tips_payment_status ON public.tips USING btree (payment_status);

CREATE INDEX idx_tips_payout_batch_id ON public.tips USING btree (payout_batch_id);

CREATE INDEX idx_tips_payout_status ON public.tips USING btree (payout_status);

CREATE INDEX idx_tips_provider_id ON public.tips USING btree (provider_id);

CREATE INDEX idx_tips_tip_given_at ON public.tips USING btree (tip_given_at);

CREATE INDEX idx_user_settings_user_id ON public.user_settings USING btree (user_id);

CREATE UNIQUE INDEX manual_bank_accounts_pkey ON public.business_manual_bank_accounts USING btree (id);

CREATE UNIQUE INDEX message_analytics_pkey ON public.message_analytics USING btree (id);

CREATE UNIQUE INDEX message_notifications_pkey ON public.message_notifications USING btree (id);

CREATE UNIQUE INDEX mfa_challenges_pkey ON public.mfa_challenges USING btree (id);

CREATE UNIQUE INDEX mfa_factors_pkey ON public.mfa_factors USING btree (id);

CREATE UNIQUE INDEX mfa_sessions_pkey ON public.mfa_sessions USING btree (id);

CREATE UNIQUE INDEX mfa_settings_pkey ON public.mfa_settings USING btree (id);

CREATE UNIQUE INDEX mfa_settings_user_id_key ON public.mfa_settings USING btree (user_id);

CREATE UNIQUE INDEX newsletter_subscribers_email_unique ON public.newsletter_subscribers USING btree (email);

CREATE UNIQUE INDEX newsletter_subscribers_pkey ON public.newsletter_subscribers USING btree (id);

CREATE UNIQUE INDEX notification_logs_pkey ON public.notification_logs USING btree (id);

CREATE UNIQUE INDEX notification_templates_pkey ON public.notification_templates USING btree (id);

CREATE UNIQUE INDEX notification_templates_template_key_key ON public.notification_templates USING btree (template_key);

CREATE UNIQUE INDEX platform_analytics_date_key ON public.platform_analytics USING btree (date);

CREATE UNIQUE INDEX platform_analytics_pkey ON public.platform_analytics USING btree (id);

CREATE UNIQUE INDEX platform_annual_tax_summary_pkey ON public.platform_annual_tax_summary USING btree (id);

CREATE UNIQUE INDEX platform_annual_tax_summary_tax_year_key ON public.platform_annual_tax_summary USING btree (tax_year);

CREATE UNIQUE INDEX promotion_usage_pkey ON public.promotion_usage USING btree (id);

CREATE UNIQUE INDEX promotion_usage_promotion_id_booking_id_key ON public.promotion_usage USING btree (promotion_id, booking_id);

CREATE UNIQUE INDEX promotions_pkey ON public.promotions USING btree (id);

CREATE UNIQUE INDEX provider_addons_pkey ON public.provider_addons USING btree (id);

CREATE UNIQUE INDEX provider_addons_provider_addon_key ON public.provider_addons USING btree (provider_id, addon_id);

CREATE UNIQUE INDEX provider_applications_pkey ON public.provider_applications USING btree (id);

CREATE UNIQUE INDEX provider_availability_exceptions_pkey ON public.provider_availability_exceptions USING btree (id);

CREATE UNIQUE INDEX provider_availability_exceptions_provider_id_exception_date_key ON public.provider_availability_exceptions USING btree (provider_id, exception_date);

CREATE UNIQUE INDEX provider_availability_pkey ON public.provider_availability USING btree (id);

CREATE UNIQUE INDEX provider_booking_preferences_pkey ON public.provider_booking_preferences USING btree (id);

CREATE UNIQUE INDEX provider_booking_preferences_provider_id_key ON public.provider_booking_preferences USING btree (provider_id);

CREATE UNIQUE INDEX provider_documents_pkey ON public.business_documents USING btree (id);

CREATE UNIQUE INDEX provider_services_pkey ON public.provider_services USING btree (id);

CREATE UNIQUE INDEX provider_services_provider_id_service_id_key ON public.provider_services USING btree (provider_id, service_id);

CREATE UNIQUE INDEX providers_pkey ON public.providers USING btree (id);

CREATE UNIQUE INDEX reviews_booking_id_unique ON public.reviews USING btree (booking_id);

CREATE UNIQUE INDEX reviews_pkey ON public.reviews USING btree (id);

CREATE UNIQUE INDEX service_addon_eligibility_pkey ON public.service_addon_eligibility USING btree (id);

CREATE UNIQUE INDEX service_addon_eligibility_service_id_addon_id_key ON public.service_addon_eligibility USING btree (service_id, addon_id);

CREATE UNIQUE INDEX service_addons_pkey ON public.service_addons USING btree (id);

CREATE UNIQUE INDEX service_categories_pkey ON public.service_categories USING btree (id);

CREATE UNIQUE INDEX service_subcategories_pkey ON public.service_subcategories USING btree (id);

CREATE UNIQUE INDEX services_pkey ON public.services USING btree (id);

CREATE UNIQUE INDEX stripe_connect_accounts_account_id_key ON public.stripe_connect_accounts USING btree (account_id);

CREATE UNIQUE INDEX stripe_connect_accounts_business_id_key ON public.stripe_connect_accounts USING btree (business_id);

CREATE UNIQUE INDEX stripe_connect_accounts_pkey ON public.stripe_connect_accounts USING btree (id);

CREATE UNIQUE INDEX stripe_identity_verifications_pkey ON public.stripe_identity_verifications USING btree (id);

CREATE UNIQUE INDEX stripe_identity_verifications_session_id_key ON public.stripe_identity_verifications USING btree (session_id);

CREATE UNIQUE INDEX stripe_tax_webhook_events_pkey ON public.stripe_tax_webhook_events USING btree (id);

CREATE UNIQUE INDEX stripe_tax_webhook_events_stripe_event_id_key ON public.stripe_tax_webhook_events USING btree (stripe_event_id);

CREATE UNIQUE INDEX system_config_config_key_key ON public.system_config USING btree (config_key);

CREATE UNIQUE INDEX system_config_pkey ON public.system_config USING btree (id);

CREATE UNIQUE INDEX tip_analytics_daily_date_key ON public.tip_analytics_daily USING btree (date);

CREATE UNIQUE INDEX tip_analytics_daily_pkey ON public.tip_analytics_daily USING btree (id);

CREATE UNIQUE INDEX tip_presets_pkey ON public.tip_presets USING btree (id);

CREATE UNIQUE INDEX tips_pkey ON public.tips USING btree (id);

CREATE UNIQUE INDEX unique_factor_id_per_user ON public.mfa_factors USING btree (user_id, factor_id);

CREATE UNIQUE INDEX user_settings_pkey ON public.user_settings USING btree (id);

CREATE UNIQUE INDEX user_settings_user_id_key ON public.user_settings USING btree (user_id);

alter table "public"."admin_users" add constraint "admin_users_pkey" PRIMARY KEY using index "admin_users_pkey";

alter table "public"."announcements" add constraint "announcements_pkey" PRIMARY KEY using index "announcements_pkey";

alter table "public"."booking_addons" add constraint "booking_addons_pkey" PRIMARY KEY using index "booking_addons_pkey";

alter table "public"."booking_changes" add constraint "booking_changes_pkey" PRIMARY KEY using index "booking_changes_pkey";

alter table "public"."bookings" add constraint "bookings_pkey" PRIMARY KEY using index "bookings_pkey";

alter table "public"."business_addons" add constraint "business_addon_pricing_pkey" PRIMARY KEY using index "business_addon_pricing_pkey";

alter table "public"."business_annual_tax_tracking" add constraint "business_annual_tax_tracking_pkey" PRIMARY KEY using index "business_annual_tax_tracking_pkey";

alter table "public"."business_documents" add constraint "provider_documents_pkey" PRIMARY KEY using index "provider_documents_pkey";

alter table "public"."business_locations" add constraint "business_locations_pkey" PRIMARY KEY using index "business_locations_pkey";

alter table "public"."business_manual_bank_accounts" add constraint "manual_bank_accounts_pkey" PRIMARY KEY using index "manual_bank_accounts_pkey";

alter table "public"."business_payment_transactions" add constraint "business_payment_transactions_pkey" PRIMARY KEY using index "business_payment_transactions_pkey";

alter table "public"."business_profiles" add constraint "business_profiles_pkey" PRIMARY KEY using index "business_profiles_pkey";

alter table "public"."business_service_categories" add constraint "business_service_categories_pkey" PRIMARY KEY using index "business_service_categories_pkey";

alter table "public"."business_service_subcategories" add constraint "business_service_subcategories_pkey" PRIMARY KEY using index "business_service_subcategories_pkey";

alter table "public"."business_services" add constraint "business_services_pkey" PRIMARY KEY using index "business_services_pkey";

alter table "public"."business_setup_progress" add constraint "business_setup_progress_pkey" PRIMARY KEY using index "business_setup_progress_pkey";

alter table "public"."business_stripe_tax_info" add constraint "business_stripe_tax_info_pkey" PRIMARY KEY using index "business_stripe_tax_info_pkey";

alter table "public"."business_subscriptions" add constraint "business_subscriptions_pkey" PRIMARY KEY using index "business_subscriptions_pkey";

alter table "public"."business_verifications" add constraint "business_verifications_pkey" PRIMARY KEY using index "business_verifications_pkey";

alter table "public"."contact_submissions" add constraint "contact_submissions_pkey" PRIMARY KEY using index "contact_submissions_pkey";

alter table "public"."conversation_metadata" add constraint "conversation_metadata_pkey" PRIMARY KEY using index "conversation_metadata_pkey";

alter table "public"."conversation_participants" add constraint "conversation_participants_pkey" PRIMARY KEY using index "conversation_participants_pkey";

alter table "public"."customer_favorite_businesses" add constraint "customer_favorite_businesses_pkey" PRIMARY KEY using index "customer_favorite_businesses_pkey";

alter table "public"."customer_favorite_providers" add constraint "customer_favorite_providers_pkey" PRIMARY KEY using index "customer_favorite_providers_pkey";

alter table "public"."customer_favorite_services" add constraint "customer_favorite_services_pkey" PRIMARY KEY using index "customer_favorite_services_pkey";

alter table "public"."customer_locations" add constraint "customer_locations_pkey" PRIMARY KEY using index "customer_locations_pkey";

alter table "public"."customer_profiles" add constraint "customer_profiles_pkey" PRIMARY KEY using index "customer_profiles_pkey";

alter table "public"."customer_stripe_profiles" add constraint "customer_stripe_profiles_pkey" PRIMARY KEY using index "customer_stripe_profiles_pkey";

alter table "public"."customer_subscriptions" add constraint "customer_subscriptions_pkey" PRIMARY KEY using index "customer_subscriptions_pkey";

alter table "public"."email_logs" add constraint "email_logs_pkey" PRIMARY KEY using index "email_logs_pkey";

alter table "public"."financial_transactions" add constraint "financial_transactions_pkey" PRIMARY KEY using index "financial_transactions_pkey";

alter table "public"."message_analytics" add constraint "message_analytics_pkey" PRIMARY KEY using index "message_analytics_pkey";

alter table "public"."message_notifications" add constraint "message_notifications_pkey" PRIMARY KEY using index "message_notifications_pkey";

alter table "public"."mfa_challenges" add constraint "mfa_challenges_pkey" PRIMARY KEY using index "mfa_challenges_pkey";

alter table "public"."mfa_factors" add constraint "mfa_factors_pkey" PRIMARY KEY using index "mfa_factors_pkey";

alter table "public"."mfa_sessions" add constraint "mfa_sessions_pkey" PRIMARY KEY using index "mfa_sessions_pkey";

alter table "public"."mfa_settings" add constraint "mfa_settings_pkey" PRIMARY KEY using index "mfa_settings_pkey";

alter table "public"."newsletter_subscribers" add constraint "newsletter_subscribers_pkey" PRIMARY KEY using index "newsletter_subscribers_pkey";

alter table "public"."notification_logs" add constraint "notification_logs_pkey" PRIMARY KEY using index "notification_logs_pkey";

alter table "public"."notification_templates" add constraint "notification_templates_pkey" PRIMARY KEY using index "notification_templates_pkey";

alter table "public"."platform_analytics" add constraint "platform_analytics_pkey" PRIMARY KEY using index "platform_analytics_pkey";

alter table "public"."platform_annual_tax_summary" add constraint "platform_annual_tax_summary_pkey" PRIMARY KEY using index "platform_annual_tax_summary_pkey";

alter table "public"."promotion_usage" add constraint "promotion_usage_pkey" PRIMARY KEY using index "promotion_usage_pkey";

alter table "public"."promotions" add constraint "promotions_pkey" PRIMARY KEY using index "promotions_pkey";

alter table "public"."provider_addons" add constraint "provider_addons_pkey" PRIMARY KEY using index "provider_addons_pkey";

alter table "public"."provider_applications" add constraint "provider_applications_pkey" PRIMARY KEY using index "provider_applications_pkey";

alter table "public"."provider_availability" add constraint "provider_availability_pkey" PRIMARY KEY using index "provider_availability_pkey";

alter table "public"."provider_availability_exceptions" add constraint "provider_availability_exceptions_pkey" PRIMARY KEY using index "provider_availability_exceptions_pkey";

alter table "public"."provider_booking_preferences" add constraint "provider_booking_preferences_pkey" PRIMARY KEY using index "provider_booking_preferences_pkey";

alter table "public"."provider_services" add constraint "provider_services_pkey" PRIMARY KEY using index "provider_services_pkey";

alter table "public"."providers" add constraint "providers_pkey" PRIMARY KEY using index "providers_pkey";

alter table "public"."reviews" add constraint "reviews_pkey" PRIMARY KEY using index "reviews_pkey";

alter table "public"."service_addon_eligibility" add constraint "service_addon_eligibility_pkey" PRIMARY KEY using index "service_addon_eligibility_pkey";

alter table "public"."service_addons" add constraint "service_addons_pkey" PRIMARY KEY using index "service_addons_pkey";

alter table "public"."service_categories" add constraint "service_categories_pkey" PRIMARY KEY using index "service_categories_pkey";

alter table "public"."service_subcategories" add constraint "service_subcategories_pkey" PRIMARY KEY using index "service_subcategories_pkey";

alter table "public"."services" add constraint "services_pkey" PRIMARY KEY using index "services_pkey";

alter table "public"."stripe_connect_accounts" add constraint "stripe_connect_accounts_pkey" PRIMARY KEY using index "stripe_connect_accounts_pkey";

alter table "public"."stripe_identity_verifications" add constraint "stripe_identity_verifications_pkey" PRIMARY KEY using index "stripe_identity_verifications_pkey";

alter table "public"."stripe_tax_webhook_events" add constraint "stripe_tax_webhook_events_pkey" PRIMARY KEY using index "stripe_tax_webhook_events_pkey";

alter table "public"."system_config" add constraint "system_config_pkey" PRIMARY KEY using index "system_config_pkey";

alter table "public"."tip_analytics_daily" add constraint "tip_analytics_daily_pkey" PRIMARY KEY using index "tip_analytics_daily_pkey";

alter table "public"."tip_presets" add constraint "tip_presets_pkey" PRIMARY KEY using index "tip_presets_pkey";

alter table "public"."tips" add constraint "tips_pkey" PRIMARY KEY using index "tips_pkey";

alter table "public"."user_settings" add constraint "user_settings_pkey" PRIMARY KEY using index "user_settings_pkey";

alter table "public"."admin_users" add constraint "admin_users_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."admin_users" validate constraint "admin_users_user_id_fkey";

alter table "public"."booking_addons" add constraint "booking_addons_addon_id_fkey" FOREIGN KEY (addon_id) REFERENCES service_addons(id) not valid;

alter table "public"."booking_addons" validate constraint "booking_addons_addon_id_fkey";

alter table "public"."booking_addons" add constraint "booking_addons_booking_id_fkey" FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE not valid;

alter table "public"."booking_addons" validate constraint "booking_addons_booking_id_fkey";

alter table "public"."booking_changes" add constraint "booking_changes_booking_id_fkey" FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE not valid;

alter table "public"."booking_changes" validate constraint "booking_changes_booking_id_fkey";

alter table "public"."booking_changes" add constraint "booking_changes_change_type_check" CHECK (((change_type)::text = ANY (ARRAY[('addon_added'::character varying)::text, ('addon_removed'::character varying)::text, ('rescheduled'::character varying)::text, ('cancelled'::character varying)::text]))) not valid;

alter table "public"."booking_changes" validate constraint "booking_changes_change_type_check";

alter table "public"."booking_changes" add constraint "booking_changes_changed_by_fkey" FOREIGN KEY (changed_by) REFERENCES auth.users(id) not valid;

alter table "public"."booking_changes" validate constraint "booking_changes_changed_by_fkey";

alter table "public"."bookings" add constraint "bookings_booking_reference_unique" UNIQUE using index "bookings_booking_reference_unique";

alter table "public"."bookings" add constraint "bookings_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) not valid;

alter table "public"."bookings" validate constraint "bookings_business_id_fkey";

alter table "public"."bookings" add constraint "bookings_business_location_id_fkey" FOREIGN KEY (business_location_id) REFERENCES business_locations(id) not valid;

alter table "public"."bookings" validate constraint "bookings_business_location_id_fkey";

alter table "public"."bookings" add constraint "bookings_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customer_profiles(id) ON DELETE RESTRICT not valid;

alter table "public"."bookings" validate constraint "bookings_customer_id_fkey";

alter table "public"."bookings" add constraint "bookings_customer_location_id_fkey" FOREIGN KEY (customer_location_id) REFERENCES customer_locations(id) not valid;

alter table "public"."bookings" validate constraint "bookings_customer_location_id_fkey";

alter table "public"."bookings" add constraint "bookings_provider_id_fkey" FOREIGN KEY (provider_id) REFERENCES providers(id) not valid;

alter table "public"."bookings" validate constraint "bookings_provider_id_fkey";

alter table "public"."bookings" add constraint "bookings_rescheduled_by_fkey" FOREIGN KEY (rescheduled_by) REFERENCES auth.users(id) not valid;

alter table "public"."bookings" validate constraint "bookings_rescheduled_by_fkey";

alter table "public"."bookings" add constraint "bookings_service_id_fkey" FOREIGN KEY (service_id) REFERENCES services(id) not valid;

alter table "public"."bookings" validate constraint "bookings_service_id_fkey";

alter table "public"."business_addons" add constraint "business_addon_pricing_addon_id_fkey" FOREIGN KEY (addon_id) REFERENCES service_addons(id) ON DELETE CASCADE not valid;

alter table "public"."business_addons" validate constraint "business_addon_pricing_addon_id_fkey";

alter table "public"."business_addons" add constraint "business_addon_pricing_business_id_addon_id_key" UNIQUE using index "business_addon_pricing_business_id_addon_id_key";

alter table "public"."business_addons" add constraint "business_addon_pricing_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) ON DELETE CASCADE not valid;

alter table "public"."business_addons" validate constraint "business_addon_pricing_business_id_fkey";

alter table "public"."business_annual_tax_tracking" add constraint "business_annual_tax_tracking_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) ON DELETE CASCADE not valid;

alter table "public"."business_annual_tax_tracking" validate constraint "business_annual_tax_tracking_business_id_fkey";

alter table "public"."business_annual_tax_tracking" add constraint "business_annual_tax_tracking_business_id_tax_year_key" UNIQUE using index "business_annual_tax_tracking_business_id_tax_year_key";

alter table "public"."business_annual_tax_tracking" add constraint "business_annual_tax_tracking_compliance_status_check" CHECK (((compliance_status)::text = ANY ((ARRAY['pending'::character varying, 'in_progress'::character varying, 'completed'::character varying, 'failed'::character varying])::text[]))) not valid;

alter table "public"."business_annual_tax_tracking" validate constraint "business_annual_tax_tracking_compliance_status_check";

alter table "public"."business_annual_tax_tracking" add constraint "business_annual_tax_tracking_tax_form_status_check" CHECK (((tax_form_status)::text = ANY ((ARRAY['pending'::character varying, 'generated'::character varying, 'sent'::character varying, 'delivered'::character varying, 'failed'::character varying])::text[]))) not valid;

alter table "public"."business_annual_tax_tracking" validate constraint "business_annual_tax_tracking_tax_form_status_check";

alter table "public"."business_documents" add constraint "business_documents_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) not valid;

alter table "public"."business_documents" validate constraint "business_documents_business_id_fkey";

alter table "public"."business_documents" add constraint "provider_documents_verified_by_fkey" FOREIGN KEY (verified_by) REFERENCES admin_users(id) not valid;

alter table "public"."business_documents" validate constraint "provider_documents_verified_by_fkey";

alter table "public"."business_locations" add constraint "business_locations_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) ON DELETE CASCADE not valid;

alter table "public"."business_locations" validate constraint "business_locations_business_id_fkey";

alter table "public"."business_manual_bank_accounts" add constraint "manual_bank_accounts_account_type_check" CHECK ((account_type = ANY (ARRAY['checking'::text, 'savings'::text]))) not valid;

alter table "public"."business_manual_bank_accounts" validate constraint "manual_bank_accounts_account_type_check";

alter table "public"."business_manual_bank_accounts" add constraint "manual_bank_accounts_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) ON DELETE CASCADE not valid;

alter table "public"."business_manual_bank_accounts" validate constraint "manual_bank_accounts_business_id_fkey";

alter table "public"."business_manual_bank_accounts" add constraint "manual_bank_accounts_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."business_manual_bank_accounts" validate constraint "manual_bank_accounts_user_id_fkey";

alter table "public"."business_manual_bank_accounts" add constraint "manual_bank_accounts_verification_status_check" CHECK ((verification_status = ANY (ARRAY['pending'::text, 'verified'::text, 'failed'::text]))) not valid;

alter table "public"."business_manual_bank_accounts" validate constraint "manual_bank_accounts_verification_status_check";

alter table "public"."business_payment_transactions" add constraint "business_payment_transactions_booking_id_fkey" FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE not valid;

alter table "public"."business_payment_transactions" validate constraint "business_payment_transactions_booking_id_fkey";

alter table "public"."business_payment_transactions" add constraint "business_payment_transactions_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) ON DELETE CASCADE not valid;

alter table "public"."business_payment_transactions" validate constraint "business_payment_transactions_business_id_fkey";

alter table "public"."business_profiles" add constraint "business_profiles_identity_verification_status_check" CHECK ((identity_verification_status = ANY (ARRAY['pending'::text, 'verified'::text, 'failed'::text, 'requires_input'::text, 'processing'::text]))) not valid;

alter table "public"."business_profiles" validate constraint "business_profiles_identity_verification_status_check";

alter table "public"."business_service_categories" add constraint "business_service_categories_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) ON DELETE CASCADE not valid;

alter table "public"."business_service_categories" validate constraint "business_service_categories_business_id_fkey";

alter table "public"."business_service_categories" add constraint "business_service_categories_category_id_fkey" FOREIGN KEY (category_id) REFERENCES service_categories(id) not valid;

alter table "public"."business_service_categories" validate constraint "business_service_categories_category_id_fkey";

alter table "public"."business_service_subcategories" add constraint "business_service_subcategories_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) ON DELETE CASCADE not valid;

alter table "public"."business_service_subcategories" validate constraint "business_service_subcategories_business_id_fkey";

alter table "public"."business_service_subcategories" add constraint "business_service_subcategories_category_id_fkey" FOREIGN KEY (category_id) REFERENCES service_categories(id) not valid;

alter table "public"."business_service_subcategories" validate constraint "business_service_subcategories_category_id_fkey";

alter table "public"."business_service_subcategories" add constraint "business_service_subcategories_subcategory_id_fkey" FOREIGN KEY (subcategory_id) REFERENCES service_subcategories(id) not valid;

alter table "public"."business_service_subcategories" validate constraint "business_service_subcategories_subcategory_id_fkey";

alter table "public"."business_services" add constraint "business_services_business_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) ON DELETE CASCADE not valid;

alter table "public"."business_services" validate constraint "business_services_business_fkey";

alter table "public"."business_services" add constraint "business_services_service_fkey" FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE not valid;

alter table "public"."business_services" validate constraint "business_services_service_fkey";

alter table "public"."business_services" add constraint "business_services_unique" UNIQUE using index "business_services_unique";

alter table "public"."business_setup_progress" add constraint "business_setup_progress_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) ON DELETE CASCADE not valid;

alter table "public"."business_setup_progress" validate constraint "business_setup_progress_business_id_fkey";

alter table "public"."business_setup_progress" add constraint "business_setup_progress_business_id_key" UNIQUE using index "business_setup_progress_business_id_key";

alter table "public"."business_stripe_tax_info" add constraint "business_stripe_tax_info_business_entity_type_check" CHECK (((business_entity_type)::text = ANY ((ARRAY['sole_proprietorship'::character varying, 'partnership'::character varying, 'llc'::character varying, 'corporation'::character varying, 'non_profit'::character varying])::text[]))) not valid;

alter table "public"."business_stripe_tax_info" validate constraint "business_stripe_tax_info_business_entity_type_check";

alter table "public"."business_stripe_tax_info" add constraint "business_stripe_tax_info_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) ON DELETE CASCADE not valid;

alter table "public"."business_stripe_tax_info" validate constraint "business_stripe_tax_info_business_id_fkey";

alter table "public"."business_stripe_tax_info" add constraint "business_stripe_tax_info_business_id_key" UNIQUE using index "business_stripe_tax_info_business_id_key";

alter table "public"."business_stripe_tax_info" add constraint "business_stripe_tax_info_tax_id_type_check" CHECK (((tax_id_type)::text = ANY ((ARRAY['EIN'::character varying, 'SSN'::character varying])::text[]))) not valid;

alter table "public"."business_stripe_tax_info" validate constraint "business_stripe_tax_info_tax_id_type_check";

alter table "public"."business_stripe_tax_info" add constraint "business_stripe_tax_info_w9_status_check" CHECK (((w9_status)::text = ANY ((ARRAY['not_collected'::character varying, 'requested'::character varying, 'received'::character varying, 'invalid'::character varying, 'expired'::character varying])::text[]))) not valid;

alter table "public"."business_stripe_tax_info" validate constraint "business_stripe_tax_info_w9_status_check";

alter table "public"."business_subscriptions" add constraint "business_subscriptions_business_id_fkey" FOREIGN KEY (business_id) REFERENCES providers(id) ON DELETE CASCADE not valid;

alter table "public"."business_subscriptions" validate constraint "business_subscriptions_business_id_fkey";

alter table "public"."business_verifications" add constraint "business_verifications_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) ON DELETE CASCADE not valid;

alter table "public"."business_verifications" validate constraint "business_verifications_business_id_fkey";

alter table "public"."business_verifications" add constraint "business_verifications_reviewed_by_fkey" FOREIGN KEY (reviewed_by) REFERENCES admin_users(id) not valid;

alter table "public"."business_verifications" validate constraint "business_verifications_reviewed_by_fkey";

alter table "public"."contact_submissions" add constraint "contact_submissions_responded_by_fkey" FOREIGN KEY (responded_by) REFERENCES auth.users(id) not valid;

alter table "public"."contact_submissions" validate constraint "contact_submissions_responded_by_fkey";

alter table "public"."contact_submissions" add constraint "contact_submissions_status_check" CHECK ((status = ANY (ARRAY['received'::text, 'in_progress'::text, 'responded'::text, 'closed'::text]))) not valid;

alter table "public"."contact_submissions" validate constraint "contact_submissions_status_check";

alter table "public"."conversation_metadata" add constraint "conversation_metadata_booking_id_fkey" FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE not valid;

alter table "public"."conversation_metadata" validate constraint "conversation_metadata_booking_id_fkey";

alter table "public"."conversation_metadata" add constraint "conversation_metadata_conversation_type_check" CHECK ((conversation_type = ANY (ARRAY['booking_chat'::text, 'support_chat'::text, 'general'::text]))) not valid;

alter table "public"."conversation_metadata" validate constraint "conversation_metadata_conversation_type_check";

alter table "public"."conversation_metadata" add constraint "conversation_metadata_twilio_conversation_sid_key" UNIQUE using index "conversation_metadata_twilio_conversation_sid_key";

alter table "public"."conversation_participants" add constraint "conversation_participants_conversation_id_fkey" FOREIGN KEY (conversation_id) REFERENCES conversation_metadata(id) ON DELETE CASCADE not valid;

alter table "public"."conversation_participants" validate constraint "conversation_participants_conversation_id_fkey";

alter table "public"."conversation_participants" add constraint "conversation_participants_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."conversation_participants" validate constraint "conversation_participants_user_id_fkey";

alter table "public"."conversation_participants" add constraint "conversation_participants_user_type_check" CHECK ((user_type = ANY (ARRAY['provider'::text, 'customer'::text, 'owner'::text, 'dispatcher'::text]))) not valid;

alter table "public"."conversation_participants" validate constraint "conversation_participants_user_type_check";

alter table "public"."customer_favorite_businesses" add constraint "customer_favorite_businesses_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) ON DELETE CASCADE not valid;

alter table "public"."customer_favorite_businesses" validate constraint "customer_favorite_businesses_business_id_fkey";

alter table "public"."customer_favorite_businesses" add constraint "customer_favorite_businesses_customer_id_business_id_key" UNIQUE using index "customer_favorite_businesses_customer_id_business_id_key";

alter table "public"."customer_favorite_businesses" add constraint "customer_favorite_businesses_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customer_profiles(id) ON DELETE CASCADE not valid;

alter table "public"."customer_favorite_businesses" validate constraint "customer_favorite_businesses_customer_id_fkey";

alter table "public"."customer_favorite_providers" add constraint "customer_favorite_providers_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customer_profiles(id) ON DELETE CASCADE not valid;

alter table "public"."customer_favorite_providers" validate constraint "customer_favorite_providers_customer_id_fkey";

alter table "public"."customer_favorite_providers" add constraint "customer_favorite_providers_customer_id_provider_id_key" UNIQUE using index "customer_favorite_providers_customer_id_provider_id_key";

alter table "public"."customer_favorite_providers" add constraint "customer_favorite_providers_provider_id_fkey" FOREIGN KEY (provider_id) REFERENCES providers(id) ON DELETE CASCADE not valid;

alter table "public"."customer_favorite_providers" validate constraint "customer_favorite_providers_provider_id_fkey";

alter table "public"."customer_favorite_services" add constraint "customer_favorite_services_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customer_profiles(id) ON DELETE CASCADE not valid;

alter table "public"."customer_favorite_services" validate constraint "customer_favorite_services_customer_id_fkey";

alter table "public"."customer_favorite_services" add constraint "customer_favorite_services_customer_id_service_id_key" UNIQUE using index "customer_favorite_services_customer_id_service_id_key";

alter table "public"."customer_favorite_services" add constraint "customer_favorite_services_service_id_fkey" FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE not valid;

alter table "public"."customer_favorite_services" validate constraint "customer_favorite_services_service_id_fkey";

alter table "public"."customer_locations" add constraint "customer_locations_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."customer_locations" validate constraint "customer_locations_customer_id_fkey";

alter table "public"."customer_profiles" add constraint "customer_profiles_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."customer_profiles" validate constraint "customer_profiles_user_id_fkey";

alter table "public"."customer_profiles" add constraint "customer_profiles_user_id_key" UNIQUE using index "customer_profiles_user_id_key";

alter table "public"."customer_stripe_profiles" add constraint "customer_stripe_profiles_stripe_customer_id_key" UNIQUE using index "customer_stripe_profiles_stripe_customer_id_key";

alter table "public"."customer_stripe_profiles" add constraint "customer_stripe_profiles_user_id_fkey" FOREIGN KEY (user_id) REFERENCES customer_profiles(user_id) ON DELETE CASCADE not valid;

alter table "public"."customer_stripe_profiles" validate constraint "customer_stripe_profiles_user_id_fkey";

alter table "public"."customer_subscriptions" add constraint "customer_subscriptions_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customer_profiles(id) ON DELETE CASCADE not valid;

alter table "public"."customer_subscriptions" validate constraint "customer_subscriptions_customer_id_fkey";

alter table "public"."email_logs" add constraint "email_logs_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) not valid;

alter table "public"."email_logs" validate constraint "email_logs_business_id_fkey";

alter table "public"."email_logs" add constraint "email_logs_customer_id_fkey" FOREIGN KEY (customer_id) REFERENCES customer_profiles(id) not valid;

alter table "public"."email_logs" validate constraint "email_logs_customer_id_fkey";

alter table "public"."email_logs" add constraint "email_logs_provider_id_fkey" FOREIGN KEY (provider_id) REFERENCES providers(id) not valid;

alter table "public"."email_logs" validate constraint "email_logs_provider_id_fkey";

alter table "public"."financial_transactions" add constraint "financial_transactions_booking_id_fkey" FOREIGN KEY (booking_id) REFERENCES bookings(id) not valid;

alter table "public"."financial_transactions" validate constraint "financial_transactions_booking_id_fkey";

alter table "public"."message_analytics" add constraint "message_analytics_booking_id_fkey" FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE not valid;

alter table "public"."message_analytics" validate constraint "message_analytics_booking_id_fkey";

alter table "public"."message_analytics" add constraint "message_analytics_conversation_id_fkey" FOREIGN KEY (conversation_id) REFERENCES conversation_metadata(id) ON DELETE CASCADE not valid;

alter table "public"."message_analytics" validate constraint "message_analytics_conversation_id_fkey";

alter table "public"."message_notifications" add constraint "message_notifications_conversation_id_fkey" FOREIGN KEY (conversation_id) REFERENCES conversation_metadata(id) ON DELETE CASCADE not valid;

alter table "public"."message_notifications" validate constraint "message_notifications_conversation_id_fkey";

alter table "public"."message_notifications" add constraint "message_notifications_notification_type_check" CHECK ((notification_type = ANY (ARRAY['message'::text, 'mention'::text, 'system'::text]))) not valid;

alter table "public"."message_notifications" validate constraint "message_notifications_notification_type_check";

alter table "public"."message_notifications" add constraint "message_notifications_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."message_notifications" validate constraint "message_notifications_user_id_fkey";

alter table "public"."mfa_challenges" add constraint "mfa_challenges_factor_id_fkey" FOREIGN KEY (factor_id) REFERENCES mfa_factors(id) ON DELETE CASCADE not valid;

alter table "public"."mfa_challenges" validate constraint "mfa_challenges_factor_id_fkey";

alter table "public"."mfa_challenges" add constraint "mfa_challenges_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."mfa_challenges" validate constraint "mfa_challenges_user_id_fkey";

alter table "public"."mfa_factors" add constraint "mfa_factors_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."mfa_factors" validate constraint "mfa_factors_user_id_fkey";

alter table "public"."mfa_factors" add constraint "unique_factor_id_per_user" UNIQUE using index "unique_factor_id_per_user";

alter table "public"."mfa_sessions" add constraint "mfa_sessions_factor_id_fkey" FOREIGN KEY (factor_id) REFERENCES mfa_factors(id) ON DELETE CASCADE not valid;

alter table "public"."mfa_sessions" validate constraint "mfa_sessions_factor_id_fkey";

alter table "public"."mfa_sessions" add constraint "mfa_sessions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."mfa_sessions" validate constraint "mfa_sessions_user_id_fkey";

alter table "public"."mfa_settings" add constraint "mfa_settings_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."mfa_settings" validate constraint "mfa_settings_user_id_fkey";

alter table "public"."mfa_settings" add constraint "mfa_settings_user_id_key" UNIQUE using index "mfa_settings_user_id_key";

alter table "public"."newsletter_subscribers" add constraint "newsletter_subscribers_email_unique" UNIQUE using index "newsletter_subscribers_email_unique";

alter table "public"."newsletter_subscribers" add constraint "newsletter_subscribers_status_check" CHECK ((status = ANY (ARRAY['active'::text, 'unsubscribed'::text, 'bounced'::text]))) not valid;

alter table "public"."newsletter_subscribers" validate constraint "newsletter_subscribers_status_check";

alter table "public"."notification_logs" add constraint "notification_logs_channel_check" CHECK ((channel = ANY (ARRAY['email'::text, 'sms'::text]))) not valid;

alter table "public"."notification_logs" validate constraint "notification_logs_channel_check";

alter table "public"."notification_logs" add constraint "notification_logs_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'sent'::text, 'delivered'::text, 'failed'::text, 'bounced'::text]))) not valid;

alter table "public"."notification_logs" validate constraint "notification_logs_status_check";

alter table "public"."notification_logs" add constraint "notification_logs_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."notification_logs" validate constraint "notification_logs_user_id_fkey";

alter table "public"."notification_templates" add constraint "notification_templates_template_key_key" UNIQUE using index "notification_templates_template_key_key";

alter table "public"."platform_analytics" add constraint "platform_analytics_date_key" UNIQUE using index "platform_analytics_date_key";

alter table "public"."platform_annual_tax_summary" add constraint "platform_annual_tax_summary_processing_status_check" CHECK (((processing_status)::text = ANY ((ARRAY['pending'::character varying, 'in_progress'::character varying, 'completed'::character varying, 'failed'::character varying])::text[]))) not valid;

alter table "public"."platform_annual_tax_summary" validate constraint "platform_annual_tax_summary_processing_status_check";

alter table "public"."platform_annual_tax_summary" add constraint "platform_annual_tax_summary_tax_year_key" UNIQUE using index "platform_annual_tax_summary_tax_year_key";

alter table "public"."promotion_usage" add constraint "promotion_usage_booking_id_fkey" FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE not valid;

alter table "public"."promotion_usage" validate constraint "promotion_usage_booking_id_fkey";

alter table "public"."promotion_usage" add constraint "promotion_usage_promotion_id_booking_id_key" UNIQUE using index "promotion_usage_promotion_id_booking_id_key";

alter table "public"."promotion_usage" add constraint "promotion_usage_promotion_id_fkey" FOREIGN KEY (promotion_id) REFERENCES promotions(id) ON DELETE CASCADE not valid;

alter table "public"."promotion_usage" validate constraint "promotion_usage_promotion_id_fkey";

alter table "public"."promotion_usage" add constraint "valid_amounts" CHECK ((final_amount = (original_amount - discount_applied))) not valid;

alter table "public"."promotion_usage" validate constraint "valid_amounts";

alter table "public"."promotion_usage" add constraint "valid_discount_applied" CHECK ((discount_applied >= (0)::numeric)) not valid;

alter table "public"."promotion_usage" validate constraint "valid_discount_applied";

alter table "public"."promotions" add constraint "promotions_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) not valid;

alter table "public"."promotions" validate constraint "promotions_business_id_fkey";

alter table "public"."promotions" add constraint "promotions_service_id_fkey" FOREIGN KEY (service_id) REFERENCES services(id) not valid;

alter table "public"."promotions" validate constraint "promotions_service_id_fkey";

alter table "public"."provider_addons" add constraint "provider_addons_addon_fkey" FOREIGN KEY (addon_id) REFERENCES service_addons(id) ON DELETE CASCADE not valid;

alter table "public"."provider_addons" validate constraint "provider_addons_addon_fkey";

alter table "public"."provider_addons" add constraint "provider_addons_provider_addon_key" UNIQUE using index "provider_addons_provider_addon_key";

alter table "public"."provider_addons" add constraint "provider_addons_provider_fkey" FOREIGN KEY (provider_id) REFERENCES providers(id) ON DELETE CASCADE not valid;

alter table "public"."provider_addons" validate constraint "provider_addons_provider_fkey";

alter table "public"."provider_applications" add constraint "provider_applications_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) not valid;

alter table "public"."provider_applications" validate constraint "provider_applications_business_id_fkey";

alter table "public"."provider_applications" add constraint "provider_applications_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) not valid;

alter table "public"."provider_applications" validate constraint "provider_applications_user_id_fkey";

alter table "public"."provider_availability" add constraint "provider_availability_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) ON DELETE CASCADE not valid;

alter table "public"."provider_availability" validate constraint "provider_availability_business_id_fkey";

alter table "public"."provider_availability" add constraint "provider_availability_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."provider_availability" validate constraint "provider_availability_created_by_fkey";

alter table "public"."provider_availability" add constraint "provider_availability_day_of_week_check" CHECK (((day_of_week >= 0) AND (day_of_week <= 6))) not valid;

alter table "public"."provider_availability" validate constraint "provider_availability_day_of_week_check";

alter table "public"."provider_availability" add constraint "provider_availability_location_type_check" CHECK ((location_type = ANY (ARRAY['mobile'::text, 'business'::text, 'both'::text]))) not valid;

alter table "public"."provider_availability" validate constraint "provider_availability_location_type_check";

alter table "public"."provider_availability" add constraint "provider_availability_provider_id_fkey" FOREIGN KEY (provider_id) REFERENCES providers(id) ON DELETE CASCADE not valid;

alter table "public"."provider_availability" validate constraint "provider_availability_provider_id_fkey";

alter table "public"."provider_availability" add constraint "provider_availability_schedule_type_check" CHECK ((schedule_type = ANY (ARRAY['weekly_recurring'::text, 'specific_date'::text, 'date_range'::text]))) not valid;

alter table "public"."provider_availability" validate constraint "provider_availability_schedule_type_check";

alter table "public"."provider_availability" add constraint "provider_availability_service_location_id_fkey" FOREIGN KEY (service_location_id) REFERENCES business_locations(id) ON DELETE SET NULL not valid;

alter table "public"."provider_availability" validate constraint "provider_availability_service_location_id_fkey";

alter table "public"."provider_availability" add constraint "recurring_schedule_needs_day" CHECK ((((schedule_type = 'weekly_recurring'::text) AND (day_of_week IS NOT NULL)) OR ((schedule_type <> 'weekly_recurring'::text) AND (day_of_week IS NULL)))) not valid;

alter table "public"."provider_availability" validate constraint "recurring_schedule_needs_day";

alter table "public"."provider_availability" add constraint "specific_schedule_needs_dates" CHECK ((((schedule_type = ANY (ARRAY['specific_date'::text, 'date_range'::text])) AND (start_date IS NOT NULL)) OR (schedule_type = 'weekly_recurring'::text))) not valid;

alter table "public"."provider_availability" validate constraint "specific_schedule_needs_dates";

alter table "public"."provider_availability" add constraint "valid_date_range" CHECK (((start_date IS NULL) OR (end_date IS NULL) OR (start_date <= end_date))) not valid;

alter table "public"."provider_availability" validate constraint "valid_date_range";

alter table "public"."provider_availability" add constraint "valid_time_range" CHECK ((start_time < end_time)) not valid;

alter table "public"."provider_availability" validate constraint "valid_time_range";

alter table "public"."provider_availability_exceptions" add constraint "provider_availability_exceptions_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."provider_availability_exceptions" validate constraint "provider_availability_exceptions_created_by_fkey";

alter table "public"."provider_availability_exceptions" add constraint "provider_availability_exceptions_exception_type_check" CHECK ((exception_type = ANY (ARRAY['unavailable'::text, 'limited_hours'::text, 'different_location'::text]))) not valid;

alter table "public"."provider_availability_exceptions" validate constraint "provider_availability_exceptions_exception_type_check";

alter table "public"."provider_availability_exceptions" add constraint "provider_availability_exceptions_provider_id_exception_date_key" UNIQUE using index "provider_availability_exceptions_provider_id_exception_date_key";

alter table "public"."provider_availability_exceptions" add constraint "provider_availability_exceptions_provider_id_fkey" FOREIGN KEY (provider_id) REFERENCES providers(id) ON DELETE CASCADE not valid;

alter table "public"."provider_availability_exceptions" validate constraint "provider_availability_exceptions_provider_id_fkey";

alter table "public"."provider_availability_exceptions" add constraint "provider_availability_exceptions_service_location_id_fkey" FOREIGN KEY (service_location_id) REFERENCES business_locations(id) ON DELETE SET NULL not valid;

alter table "public"."provider_availability_exceptions" validate constraint "provider_availability_exceptions_service_location_id_fkey";

alter table "public"."provider_booking_preferences" add constraint "provider_booking_preferences_provider_id_fkey" FOREIGN KEY (provider_id) REFERENCES providers(id) ON DELETE CASCADE not valid;

alter table "public"."provider_booking_preferences" validate constraint "provider_booking_preferences_provider_id_fkey";

alter table "public"."provider_booking_preferences" add constraint "provider_booking_preferences_provider_id_key" UNIQUE using index "provider_booking_preferences_provider_id_key";

alter table "public"."provider_services" add constraint "provider_services_provider_id_fkey" FOREIGN KEY (provider_id) REFERENCES providers(id) ON DELETE CASCADE not valid;

alter table "public"."provider_services" validate constraint "provider_services_provider_id_fkey";

alter table "public"."provider_services" add constraint "provider_services_provider_id_service_id_key" UNIQUE using index "provider_services_provider_id_service_id_key";

alter table "public"."provider_services" add constraint "provider_services_service_id_fkey" FOREIGN KEY (service_id) REFERENCES services(id) not valid;

alter table "public"."provider_services" validate constraint "provider_services_service_id_fkey";

alter table "public"."providers" add constraint "providers_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) not valid;

alter table "public"."providers" validate constraint "providers_business_id_fkey";

alter table "public"."providers" add constraint "providers_location_id_fkey" FOREIGN KEY (location_id) REFERENCES business_locations(id) not valid;

alter table "public"."providers" validate constraint "providers_location_id_fkey";

alter table "public"."providers" add constraint "providers_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."providers" validate constraint "providers_user_id_fkey";

alter table "public"."reviews" add constraint "reviews_booking_id_fkey" FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE not valid;

alter table "public"."reviews" validate constraint "reviews_booking_id_fkey";

alter table "public"."reviews" add constraint "reviews_booking_id_unique" UNIQUE using index "reviews_booking_id_unique";

alter table "public"."reviews" add constraint "reviews_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) not valid;

alter table "public"."reviews" validate constraint "reviews_business_id_fkey";

alter table "public"."reviews" add constraint "reviews_communication_rating_check" CHECK (((communication_rating >= 1) AND (communication_rating <= 5))) not valid;

alter table "public"."reviews" validate constraint "reviews_communication_rating_check";

alter table "public"."reviews" add constraint "reviews_moderated_by_fkey" FOREIGN KEY (moderated_by) REFERENCES admin_users(id) not valid;

alter table "public"."reviews" validate constraint "reviews_moderated_by_fkey";

alter table "public"."reviews" add constraint "reviews_overall_rating_check" CHECK (((overall_rating >= 1) AND (overall_rating <= 5))) not valid;

alter table "public"."reviews" validate constraint "reviews_overall_rating_check";

alter table "public"."reviews" add constraint "reviews_provider_id_fkey" FOREIGN KEY (provider_id) REFERENCES providers(id) not valid;

alter table "public"."reviews" validate constraint "reviews_provider_id_fkey";

alter table "public"."reviews" add constraint "reviews_punctuality_rating_check" CHECK (((punctuality_rating >= 1) AND (punctuality_rating <= 5))) not valid;

alter table "public"."reviews" validate constraint "reviews_punctuality_rating_check";

alter table "public"."reviews" add constraint "reviews_service_rating_check" CHECK (((service_rating >= 1) AND (service_rating <= 5))) not valid;

alter table "public"."reviews" validate constraint "reviews_service_rating_check";

alter table "public"."service_addon_eligibility" add constraint "service_addon_eligibility_addon_id_fkey" FOREIGN KEY (addon_id) REFERENCES service_addons(id) ON DELETE CASCADE not valid;

alter table "public"."service_addon_eligibility" validate constraint "service_addon_eligibility_addon_id_fkey";

alter table "public"."service_addon_eligibility" add constraint "service_addon_eligibility_service_id_addon_id_key" UNIQUE using index "service_addon_eligibility_service_id_addon_id_key";

alter table "public"."service_addon_eligibility" add constraint "service_addon_eligibility_service_id_fkey" FOREIGN KEY (service_id) REFERENCES services(id) not valid;

alter table "public"."service_addon_eligibility" validate constraint "service_addon_eligibility_service_id_fkey";

alter table "public"."service_subcategories" add constraint "service_subcategories_category_id_fkey" FOREIGN KEY (category_id) REFERENCES service_categories(id) ON DELETE CASCADE not valid;

alter table "public"."service_subcategories" validate constraint "service_subcategories_category_id_fkey";

alter table "public"."services" add constraint "services_subcategory_id_fkey" FOREIGN KEY (subcategory_id) REFERENCES service_subcategories(id) not valid;

alter table "public"."services" validate constraint "services_subcategory_id_fkey";

alter table "public"."stripe_connect_accounts" add constraint "stripe_connect_accounts_account_id_key" UNIQUE using index "stripe_connect_accounts_account_id_key";

alter table "public"."stripe_connect_accounts" add constraint "stripe_connect_accounts_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) not valid;

alter table "public"."stripe_connect_accounts" validate constraint "stripe_connect_accounts_business_id_fkey";

alter table "public"."stripe_connect_accounts" add constraint "stripe_connect_accounts_business_id_key" UNIQUE using index "stripe_connect_accounts_business_id_key";

alter table "public"."stripe_connect_accounts" add constraint "stripe_connect_accounts_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) not valid;

alter table "public"."stripe_connect_accounts" validate constraint "stripe_connect_accounts_user_id_fkey";

alter table "public"."stripe_identity_verifications" add constraint "stripe_identity_verifications_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) not valid;

alter table "public"."stripe_identity_verifications" validate constraint "stripe_identity_verifications_business_id_fkey";

alter table "public"."stripe_identity_verifications" add constraint "stripe_identity_verifications_session_id_key" UNIQUE using index "stripe_identity_verifications_session_id_key";

alter table "public"."stripe_identity_verifications" add constraint "stripe_identity_verifications_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) not valid;

alter table "public"."stripe_identity_verifications" validate constraint "stripe_identity_verifications_user_id_fkey";

alter table "public"."stripe_tax_webhook_events" add constraint "stripe_tax_webhook_events_business_id_fkey" FOREIGN KEY (business_id) REFERENCES business_profiles(id) not valid;

alter table "public"."stripe_tax_webhook_events" validate constraint "stripe_tax_webhook_events_business_id_fkey";

alter table "public"."stripe_tax_webhook_events" add constraint "stripe_tax_webhook_events_stripe_event_id_key" UNIQUE using index "stripe_tax_webhook_events_stripe_event_id_key";

alter table "public"."system_config" add constraint "system_config_config_key_key" UNIQUE using index "system_config_config_key_key";

alter table "public"."tip_analytics_daily" add constraint "tip_analytics_daily_date_key" UNIQUE using index "tip_analytics_daily_date_key";

alter table "public"."tip_presets" add constraint "tip_presets_preset_type_check" CHECK (((preset_type)::text = ANY (ARRAY[('percentage'::character varying)::text, ('fixed_amount'::character varying)::text]))) not valid;

alter table "public"."tip_presets" validate constraint "tip_presets_preset_type_check";

alter table "public"."tip_presets" add constraint "tip_presets_service_category_id_fkey" FOREIGN KEY (service_category_id) REFERENCES service_categories(id) ON DELETE CASCADE not valid;

alter table "public"."tip_presets" validate constraint "tip_presets_service_category_id_fkey";

alter table "public"."tips" add constraint "tips_booking_id_fkey" FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE not valid;

alter table "public"."tips" validate constraint "tips_booking_id_fkey";

alter table "public"."tips" add constraint "tips_tip_amount_check" CHECK ((tip_amount > (0)::numeric)) not valid;

alter table "public"."tips" validate constraint "tips_tip_amount_check";

alter table "public"."user_settings" add constraint "user_settings_theme_check" CHECK ((theme = ANY (ARRAY['light'::text, 'dark'::text, 'system'::text]))) not valid;

alter table "public"."user_settings" validate constraint "user_settings_theme_check";

alter table "public"."user_settings" add constraint "user_settings_time_format_check" CHECK ((time_format = ANY (ARRAY['12h'::text, '24h'::text]))) not valid;

alter table "public"."user_settings" validate constraint "user_settings_time_format_check";

alter table "public"."user_settings" add constraint "user_settings_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."user_settings" validate constraint "user_settings_user_id_fkey";

alter table "public"."user_settings" add constraint "user_settings_user_id_key" UNIQUE using index "user_settings_user_id_key";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.add_business_to_favorites(business_id_param uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
DECLARE
    customer_id_var UUID;
BEGIN
    -- Ensure customer profile exists and get ID
    customer_id_var := public.ensure_customer_profile();
    
    -- Check if already favorited
    IF EXISTS (
        SELECT 1 
        FROM public.customer_favorite_businesses 
        WHERE customer_id = customer_id_var AND business_id = business_id_param
    ) THEN
        RETURN TRUE; -- Already favorited
    END IF;
    
    -- Check if business exists
    IF NOT EXISTS (SELECT 1 FROM public.business_profiles WHERE id = business_id_param) THEN
        RAISE EXCEPTION 'Business does not exist';
    END IF;
    
    -- Add to favorites
    INSERT INTO public.customer_favorite_businesses (
        customer_id,
        business_id,
        created_at
    ) VALUES (
        customer_id_var,
        business_id_param,
        NOW()
    );
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error adding business to favorites: %', SQLERRM;
        RETURN FALSE;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.add_favorite_business(business_id_param uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
    customer_id_var UUID;
    result_id UUID;
BEGIN
    -- Get the customer_id for the current user
    SELECT id INTO customer_id_var 
    FROM public.customer_profiles 
    WHERE user_id = auth.uid();
    
    IF customer_id_var IS NULL THEN
        RAISE EXCEPTION 'Customer profile not found';
    END IF;
    
    -- Insert the favorite business
    INSERT INTO public.customer_favorite_businesses (customer_id, business_id)
    VALUES (customer_id_var, business_id_param)
    ON CONFLICT (customer_id, business_id) DO NOTHING
    RETURNING id INTO result_id;
    
    RETURN result_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.add_favorite_provider(provider_id_param uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
    customer_id_var UUID;
    result_id UUID;
BEGIN
    -- Get the customer_id for the current user
    SELECT id INTO customer_id_var 
    FROM public.customer_profiles 
    WHERE user_id = auth.uid();
    
    IF customer_id_var IS NULL THEN
        RAISE EXCEPTION 'Customer profile not found';
    END IF;
    
    -- Insert the favorite provider
    INSERT INTO public.customer_favorite_providers (customer_id, provider_id)
    VALUES (customer_id_var, provider_id_param)
    ON CONFLICT (customer_id, provider_id) DO NOTHING
    RETURNING id INTO result_id;
    
    RETURN result_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.add_favorite_service(service_id_param uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
    customer_id_var UUID;
    result_id UUID;
BEGIN
    -- Get the customer_id for the current user
    SELECT id INTO customer_id_var 
    FROM public.customer_profiles 
    WHERE user_id = auth.uid();
    
    IF customer_id_var IS NULL THEN
        RAISE EXCEPTION 'Customer profile not found';
    END IF;
    
    -- Insert the favorite service
    INSERT INTO public.customer_favorite_services (customer_id, service_id)
    VALUES (customer_id_var, service_id_param)
    ON CONFLICT (customer_id, service_id) DO NOTHING
    RETURNING id INTO result_id;
    
    RETURN result_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.add_provider_to_favorites(provider_id_param uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
DECLARE
    customer_id_var UUID;
BEGIN
    -- Ensure customer profile exists and get ID
    customer_id_var := public.ensure_customer_profile();
    
    -- Check if already favorited
    IF EXISTS (
        SELECT 1 
        FROM public.customer_favorite_providers 
        WHERE customer_id = customer_id_var AND provider_id = provider_id_param
    ) THEN
        RETURN TRUE; -- Already favorited
    END IF;
    
    -- Check if provider exists
    IF NOT EXISTS (SELECT 1 FROM public.providers WHERE id = provider_id_param) THEN
        RAISE EXCEPTION 'Provider does not exist';
    END IF;
    
    -- Add to favorites
    INSERT INTO public.customer_favorite_providers (
        customer_id,
        provider_id,
        created_at
    ) VALUES (
        customer_id_var,
        provider_id_param,
        NOW()
    );
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error adding provider to favorites: %', SQLERRM;
        RETURN FALSE;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.add_service_to_favorites(service_id_param uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
DECLARE
    customer_id_var UUID;
BEGIN
    -- Ensure customer profile exists and get ID
    customer_id_var := public.ensure_customer_profile();
    
    -- Check if already favorited
    IF EXISTS (
        SELECT 1 
        FROM public.customer_favorite_services 
        WHERE customer_id = customer_id_var AND service_id = service_id_param
    ) THEN
        RETURN TRUE; -- Already favorited
    END IF;
    
    -- Check if service exists
    IF NOT EXISTS (SELECT 1 FROM public.services WHERE id = service_id_param) THEN
        RAISE EXCEPTION 'Service does not exist';
    END IF;
    
    -- Add to favorites
    INSERT INTO public.customer_favorite_services (
        customer_id,
        service_id,
        created_at
    ) VALUES (
        customer_id_var,
        service_id_param,
        NOW()
    );
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error adding service to favorites: %', SQLERRM;
        RETURN FALSE;
END;
$function$
;

create or replace view "public"."admin_booking_reports_view" as  SELECT b.id,
    b.booking_reference,
    b.booking_date,
    b.start_time,
    b.created_at,
    b.booking_status,
    b.total_amount AS amount,
    b.payment_status,
    s.id AS service_id,
    s.name AS service_name,
    bp.id AS business_id,
    bp.business_name,
    cp.id AS customer_id,
    cp.first_name AS customer_first_name,
    cp.last_name AS customer_last_name,
    COALESCE(concat(cp.first_name, ' ', cp.last_name), b.guest_name, 'Guest'::text) AS customer_name,
    b.guest_name,
    b.guest_email,
    b.guest_phone,
    p.id AS provider_id,
    p.first_name AS provider_first_name,
    p.last_name AS provider_last_name,
    concat(p.first_name, ' ', p.last_name) AS provider_name,
    r.id AS review_id,
    r.overall_rating AS rating,
    r.review_text AS review,
    r.is_approved AS review_approved,
    r.created_at AS review_created_at
   FROM (((((bookings b
     JOIN services s ON ((b.service_id = s.id)))
     JOIN business_profiles bp ON ((b.business_id = bp.id)))
     LEFT JOIN customer_profiles cp ON ((b.customer_id = cp.id)))
     LEFT JOIN providers p ON ((b.provider_id = p.id)))
     LEFT JOIN reviews r ON ((b.id = r.booking_id)));


create or replace view "public"."admin_bookings_enriched" as  SELECT b.id,
    b.customer_id,
    b.provider_id,
    b.service_id,
    b.booking_date,
    b.start_time,
    b.booking_status,
    b.total_amount,
    b.service_fee,
    b.remaining_balance,
    b.cancellation_fee,
    b.refund_amount,
    b.special_instructions,
    b.payment_status,
    b.cancellation_reason,
    b.booking_reference,
    b.business_id AS booking_business_id,
    b.delivery_type,
    b.tip_amount,
    b.tip_status,
    b.tip_eligible,
    b.guest_name,
    b.guest_email,
    b.guest_phone,
    b.created_at,
    b.cancelled_at,
    b.rescheduled_at,
    b.original_booking_date,
    b.original_start_time,
    b.reschedule_count,
    cp.first_name AS customer_first_name,
    cp.last_name AS customer_last_name,
    cp.email AS customer_email,
    cp.phone AS customer_phone,
    concat(cp.first_name, ' ', cp.last_name) AS customer_name,
    p.first_name AS provider_first_name,
    p.last_name AS provider_last_name,
    p.email AS provider_email,
    p.business_id,
    concat(p.first_name, ' ', p.last_name) AS provider_name,
    bp.business_name,
    bp.business_type,
    s.name AS service_name,
    s.min_price AS service_price,
    s.duration_minutes AS service_duration,
    s.description AS service_description,
    s.is_featured AS service_is_featured,
    s.is_popular AS service_is_popular,
    s.image_url AS service_image_url,
    ss.id AS service_subcategory_id,
    ss.service_subcategory_type AS service_subcategory,
    ss.description AS service_subcategory_description,
    sc.id AS service_category_id,
    sc.service_category_type AS service_category,
    sc.description AS service_category_description,
    r.id AS review_id,
    r.overall_rating,
    r.service_rating,
    r.communication_rating,
    r.punctuality_rating,
    r.review_text,
    r.is_approved AS review_is_approved,
    r.is_featured AS review_is_featured,
    r.created_at AS review_created_at,
        CASE
            WHEN (r.id IS NOT NULL) THEN true
            ELSE false
        END AS has_review,
    ft.id AS payment_id,
    ft.stripe_transaction_id,
    ft.amount AS amount_paid,
    ft.processed_at AS payment_date,
    ft.status AS transaction_status,
    ft.transaction_type,
    ft.payment_method AS transaction_payment_method,
    concat(b.booking_date, 'T', b.start_time) AS booking_datetime,
    concat(COALESCE(s.duration_minutes, 60), ' minutes') AS duration_display,
    EXTRACT(epoch FROM (((((b.booking_date || ' '::text) || b.start_time))::timestamp without time zone)::timestamp with time zone - CURRENT_TIMESTAMP)) AS seconds_until_booking,
        CASE
            WHEN (b.booking_date < CURRENT_DATE) THEN 'past'::text
            WHEN (b.booking_date = CURRENT_DATE) THEN 'today'::text
            WHEN (b.booking_date = (CURRENT_DATE + '1 day'::interval)) THEN 'tomorrow'::text
            ELSE 'future'::text
        END AS booking_time_category
   FROM ((((((((bookings b
     LEFT JOIN customer_profiles cp ON ((b.customer_id = cp.id)))
     LEFT JOIN providers p ON ((b.provider_id = p.id)))
     LEFT JOIN business_profiles bp ON ((p.business_id = bp.id)))
     LEFT JOIN services s ON ((b.service_id = s.id)))
     LEFT JOIN service_subcategories ss ON ((s.subcategory_id = ss.id)))
     LEFT JOIN service_categories sc ON ((ss.category_id = sc.id)))
     LEFT JOIN reviews r ON ((b.id = r.booking_id)))
     LEFT JOIN financial_transactions ft ON (((b.id = ft.booking_id) AND (ft.transaction_type = 'booking_payment'::transaction_type))));


create or replace view "public"."admin_business_approvals_view" as  SELECT bp.id,
    bp.business_name,
    bp.contact_email,
    bp.phone,
    bp.verification_status,
    bp.stripe_account_id,
    bp.is_active,
    bp.created_at,
    bp.image_url,
    bp.website_url,
    bp.logo_url,
    bp.cover_image_url,
    bp.business_hours,
    bp.social_media,
    bp.verification_notes,
    bp.business_type,
    bp.setup_completed,
    bp.setup_step,
    bp.is_featured,
    bp.identity_verified,
    bp.identity_verified_at,
    bp.bank_connected,
    bp.bank_connected_at,
    bp.application_submitted_at,
    bp.approved_at,
    bp.approved_by,
    bp.approval_notes,
    bp.business_description,
    COALESCE(doc_stats.total_documents, (0)::bigint) AS total_documents,
    COALESCE(doc_stats.verified_documents, (0)::bigint) AS verified_documents,
    COALESCE(doc_stats.pending_documents, (0)::bigint) AS pending_documents,
    COALESCE(doc_stats.rejected_documents, (0)::bigint) AS rejected_documents,
    COALESCE(doc_stats.under_review_documents, (0)::bigint) AS under_review_documents,
        CASE
            WHEN (COALESCE(doc_stats.total_documents, (0)::bigint) = 0) THEN (0)::numeric
            ELSE round((((COALESCE(doc_stats.verified_documents, (0)::bigint))::numeric / (doc_stats.total_documents)::numeric) * (100)::numeric), 0)
        END AS verification_progress,
        CASE
            WHEN (bp.verification_status = 'pending'::verification_status) THEN true
            WHEN (bp.verification_status = 'suspended'::verification_status) THEN true
            ELSE false
        END AS requires_attention,
        CASE
            WHEN (bp.application_submitted_at IS NOT NULL) THEN EXTRACT(day FROM (CURRENT_TIMESTAMP - bp.application_submitted_at))
            ELSE EXTRACT(day FROM (CURRENT_TIMESTAMP - bp.created_at))
        END AS days_pending
   FROM (business_profiles bp
     LEFT JOIN ( SELECT business_documents.business_id,
            count(*) AS total_documents,
            count(*) FILTER (WHERE (business_documents.verification_status = 'verified'::business_document_status)) AS verified_documents,
            count(*) FILTER (WHERE (business_documents.verification_status = 'pending'::business_document_status)) AS pending_documents,
            count(*) FILTER (WHERE (business_documents.verification_status = 'rejected'::business_document_status)) AS rejected_documents,
            count(*) FILTER (WHERE (business_documents.verification_status = 'under_review'::business_document_status)) AS under_review_documents
           FROM business_documents
          GROUP BY business_documents.business_id) doc_stats ON ((bp.id = doc_stats.business_id)));


create or replace view "public"."admin_business_reports_view" as  SELECT bp.id,
    bp.business_name,
    bp.business_type,
    bp.verification_status,
    bp.is_active,
    bp.created_at,
    bp.contact_email,
    bp.phone,
    bl.city AS business_city,
    bl.state AS business_state,
    bl.postal_code AS business_postal_code,
        CASE
            WHEN ((bl.city IS NOT NULL) AND (bl.state IS NOT NULL)) THEN concat(bl.city, ', ', bl.state, COALESCE((' '::text || (bl.postal_code)::text), ''::text))
            ELSE 'Unknown'::text
        END AS location,
    COALESCE(provider_stats.total_providers, (0)::bigint) AS total_providers,
    COALESCE(provider_stats.active_providers, (0)::bigint) AS active_providers,
    COALESCE(service_stats.total_services, (0)::bigint) AS total_services,
    COALESCE(service_stats.active_services, (0)::bigint) AS active_services,
    COALESCE(booking_stats.total_bookings, (0)::bigint) AS total_bookings,
    COALESCE(booking_stats.completed_bookings, (0)::bigint) AS completed_bookings,
    COALESCE(booking_stats.cancelled_bookings, (0)::bigint) AS cancelled_bookings,
    COALESCE(booking_stats.total_revenue, (0)::numeric) AS total_revenue,
    COALESCE(booking_stats.completed_revenue, (0)::numeric) AS completed_revenue,
    COALESCE(rating_stats.avg_rating, (0)::numeric) AS avg_rating,
    COALESCE(rating_stats.total_reviews, (0)::bigint) AS total_reviews,
    COALESCE(rating_stats.approved_reviews, (0)::bigint) AS approved_reviews
   FROM (((((business_profiles bp
     LEFT JOIN business_locations bl ON (((bp.id = bl.business_id) AND (bl.is_primary = true))))
     LEFT JOIN LATERAL ( SELECT count(DISTINCT p.id) AS total_providers,
            count(DISTINCT p.id) FILTER (WHERE (p.is_active = true)) AS active_providers
           FROM providers p
          WHERE (p.business_id = bp.id)) provider_stats ON (true))
     LEFT JOIN LATERAL ( SELECT count(DISTINCT bs.id) AS total_services,
            count(DISTINCT bs.id) FILTER (WHERE (bs.is_active = true)) AS active_services
           FROM business_services bs
          WHERE (bs.business_id = bp.id)) service_stats ON (true))
     LEFT JOIN LATERAL ( SELECT count(DISTINCT b.id) AS total_bookings,
            count(DISTINCT b.id) FILTER (WHERE (b.booking_status = 'completed'::booking_status)) AS completed_bookings,
            count(DISTINCT b.id) FILTER (WHERE (b.booking_status = ANY (ARRAY['cancelled'::booking_status, 'no_show'::booking_status]))) AS cancelled_bookings,
            sum(b.total_amount) AS total_revenue,
            sum(b.total_amount) FILTER (WHERE (b.booking_status = 'completed'::booking_status)) AS completed_revenue
           FROM bookings b
          WHERE (b.business_id = bp.id)) booking_stats ON (true))
     LEFT JOIN LATERAL ( SELECT avg(r.overall_rating) AS avg_rating,
            count(r.id) AS total_reviews,
            count(r.id) FILTER (WHERE (r.is_approved = true)) AS approved_reviews
           FROM reviews r
          WHERE (r.business_id = bp.id)) rating_stats ON (true));


create or replace view "public"."admin_dashboard_stats" as  SELECT ( SELECT count(*) AS count
           FROM bookings) AS total_bookings,
    ( SELECT count(*) AS count
           FROM bookings
          WHERE (bookings.booking_status = 'completed'::booking_status)) AS completed_bookings,
    ( SELECT count(*) AS count
           FROM bookings
          WHERE (bookings.booking_status = 'cancelled'::booking_status)) AS cancelled_bookings,
    ( SELECT count(*) AS count
           FROM bookings
          WHERE (bookings.booking_status = 'pending'::booking_status)) AS pending_bookings,
    ( SELECT count(*) AS count
           FROM bookings
          WHERE (bookings.booking_status = 'confirmed'::booking_status)) AS confirmed_bookings,
    ( SELECT count(*) AS count
           FROM bookings
          WHERE (bookings.booking_status = 'in_progress'::booking_status)) AS in_progress_bookings,
        CASE
            WHEN (( SELECT count(*) AS count
               FROM bookings) > 0) THEN round((((( SELECT count(*) AS count
               FROM bookings
              WHERE (bookings.booking_status = 'completed'::booking_status)))::numeric / (( SELECT count(*) AS count
               FROM bookings))::numeric) * (100)::numeric), 2)
            ELSE (0)::numeric
        END AS completion_rate_percent,
        CASE
            WHEN (( SELECT count(*) AS count
               FROM bookings) > 0) THEN round((((( SELECT count(*) AS count
               FROM bookings
              WHERE (bookings.booking_status = 'cancelled'::booking_status)))::numeric / (( SELECT count(*) AS count
               FROM bookings))::numeric) * (100)::numeric), 2)
            ELSE (0)::numeric
        END AS cancellation_rate_percent,
    ( SELECT COALESCE(sum(bookings.total_amount), (0)::numeric) AS "coalesce"
           FROM bookings
          WHERE (bookings.booking_status = 'completed'::booking_status)) AS total_revenue,
    ( SELECT COALESCE(sum(bookings.total_amount), (0)::numeric) AS "coalesce"
           FROM bookings
          WHERE (bookings.booking_status = ANY (ARRAY['pending'::booking_status, 'confirmed'::booking_status, 'in_progress'::booking_status]))) AS pending_revenue,
        CASE
            WHEN (( SELECT count(*) AS count
               FROM bookings
              WHERE (bookings.booking_status = 'completed'::booking_status)) > 0) THEN round((( SELECT COALESCE(sum(bookings.total_amount), (0)::numeric) AS "coalesce"
               FROM bookings
              WHERE (bookings.booking_status = 'completed'::booking_status)) / (( SELECT count(*) AS count
               FROM bookings
              WHERE (bookings.booking_status = 'completed'::booking_status)))::numeric), 2)
            ELSE (0)::numeric
        END AS average_booking_value,
    ( SELECT count(*) AS count
           FROM customer_profiles) AS total_customers,
    ( SELECT count(*) AS count
           FROM customer_profiles
          WHERE (customer_profiles.is_active = true)) AS active_customers,
    ( SELECT count(*) AS count
           FROM providers) AS total_providers,
    ( SELECT count(*) AS count
           FROM providers
          WHERE (providers.is_active = true)) AS active_providers,
    ( SELECT count(*) AS count
           FROM business_profiles) AS total_businesses,
    ( SELECT count(*) AS count
           FROM business_profiles
          WHERE (business_profiles.is_active = true)) AS active_businesses,
    ( SELECT count(*) AS count
           FROM business_profiles
          WHERE (business_profiles.verification_status = 'approved'::verification_status)) AS approved_businesses,
    ( SELECT count(*) AS count
           FROM business_profiles
          WHERE (business_profiles.verification_status = 'pending'::verification_status)) AS pending_businesses,
    ( SELECT count(*) AS count
           FROM business_profiles
          WHERE (business_profiles.verification_status = 'rejected'::verification_status)) AS rejected_businesses,
    ( SELECT count(*) AS count
           FROM services) AS total_services,
    ( SELECT count(*) AS count
           FROM services
          WHERE (services.is_active = true)) AS active_services,
    ( SELECT count(*) AS count
           FROM reviews) AS total_reviews,
    ( SELECT count(*) AS count
           FROM reviews
          WHERE (reviews.is_approved = true)) AS approved_reviews,
    ( SELECT count(*) AS count
           FROM reviews
          WHERE (reviews.is_featured = true)) AS featured_reviews,
    ( SELECT round(avg(reviews.overall_rating), 2) AS round
           FROM reviews
          WHERE (reviews.is_approved = true)) AS average_rating,
    ( SELECT count(*) AS count
           FROM financial_transactions
          WHERE (financial_transactions.transaction_type = 'booking_payment'::transaction_type)) AS total_payment_transactions,
    ( SELECT COALESCE(sum(financial_transactions.amount), (0)::numeric) AS "coalesce"
           FROM financial_transactions
          WHERE ((financial_transactions.transaction_type = 'booking_payment'::transaction_type) AND (financial_transactions.status = 'completed'::status))) AS total_payments_amount,
    ( SELECT count(*) AS count
           FROM financial_transactions
          WHERE (financial_transactions.transaction_type = 'refund'::transaction_type)) AS total_refund_transactions,
    ( SELECT COALESCE(sum(financial_transactions.amount), (0)::numeric) AS "coalesce"
           FROM financial_transactions
          WHERE ((financial_transactions.transaction_type = 'refund'::transaction_type) AND (financial_transactions.status = 'completed'::status))) AS total_refunds_amount,
    ( SELECT count(DISTINCT financial_transactions.transaction_type) AS count
           FROM financial_transactions) AS transaction_types_count,
    ( SELECT count(*) AS count
           FROM bookings
          WHERE (bookings.created_at >= (CURRENT_DATE - '30 days'::interval))) AS bookings_last_30_days,
    ( SELECT count(*) AS count
           FROM customer_profiles
          WHERE (customer_profiles.created_at >= (CURRENT_DATE - '30 days'::interval))) AS new_customers_last_30_days,
    ( SELECT count(*) AS count
           FROM providers
          WHERE (providers.created_at >= (CURRENT_DATE - '30 days'::interval))) AS new_providers_last_30_days,
    ( SELECT count(*) AS count
           FROM business_profiles
          WHERE (business_profiles.created_at >= (CURRENT_DATE - '30 days'::interval))) AS new_businesses_last_30_days,
    ( SELECT COALESCE(sum(bookings.total_amount), (0)::numeric) AS "coalesce"
           FROM bookings
          WHERE ((bookings.booking_status = 'completed'::booking_status) AND (bookings.created_at >= (CURRENT_DATE - '30 days'::interval)))) AS revenue_last_30_days,
    ( SELECT count(*) AS count
           FROM bookings
          WHERE (date(bookings.created_at) = CURRENT_DATE)) AS bookings_today,
    ( SELECT count(*) AS count
           FROM bookings
          WHERE (bookings.booking_date = CURRENT_DATE)) AS bookings_scheduled_today,
    ( SELECT COALESCE(sum(bookings.total_amount), (0)::numeric) AS "coalesce"
           FROM bookings
          WHERE ((bookings.booking_status = 'completed'::booking_status) AND (date(bookings.created_at) = CURRENT_DATE))) AS revenue_today,
        CASE
            WHEN (( SELECT count(*) AS count
               FROM bookings
              WHERE ((bookings.created_at >= (CURRENT_DATE - '60 days'::interval)) AND (bookings.created_at < (CURRENT_DATE - '30 days'::interval)))) > 0) THEN round(((((( SELECT count(*) AS count
               FROM bookings
              WHERE (bookings.created_at >= (CURRENT_DATE - '30 days'::interval))))::numeric - (( SELECT count(*) AS count
               FROM bookings
              WHERE ((bookings.created_at >= (CURRENT_DATE - '60 days'::interval)) AND (bookings.created_at < (CURRENT_DATE - '30 days'::interval)))))::numeric) / (( SELECT count(*) AS count
               FROM bookings
              WHERE ((bookings.created_at >= (CURRENT_DATE - '60 days'::interval)) AND (bookings.created_at < (CURRENT_DATE - '30 days'::interval)))))::numeric) * (100)::numeric), 2)
            ELSE (0)::numeric
        END AS bookings_growth_percent,
        CASE
            WHEN (( SELECT COALESCE(sum(bookings.total_amount), (0)::numeric) AS "coalesce"
               FROM bookings
              WHERE ((bookings.booking_status = 'completed'::booking_status) AND (bookings.created_at >= (CURRENT_DATE - '60 days'::interval)) AND (bookings.created_at < (CURRENT_DATE - '30 days'::interval)))) > (0)::numeric) THEN round((((( SELECT COALESCE(sum(bookings.total_amount), (0)::numeric) AS "coalesce"
               FROM bookings
              WHERE ((bookings.booking_status = 'completed'::booking_status) AND (bookings.created_at >= (CURRENT_DATE - '30 days'::interval)))) - ( SELECT COALESCE(sum(bookings.total_amount), (0)::numeric) AS "coalesce"
               FROM bookings
              WHERE ((bookings.booking_status = 'completed'::booking_status) AND (bookings.created_at >= (CURRENT_DATE - '60 days'::interval)) AND (bookings.created_at < (CURRENT_DATE - '30 days'::interval))))) / ( SELECT COALESCE(sum(bookings.total_amount), (0)::numeric) AS "coalesce"
               FROM bookings
              WHERE ((bookings.booking_status = 'completed'::booking_status) AND (bookings.created_at >= (CURRENT_DATE - '60 days'::interval)) AND (bookings.created_at < (CURRENT_DATE - '30 days'::interval))))) * (100)::numeric), 2)
            ELSE (0)::numeric
        END AS revenue_growth_percent,
    CURRENT_TIMESTAMP AS stats_generated_at;


create or replace view "public"."admin_financial_overview" as  SELECT ft.id AS transaction_id,
    ft.booking_id,
    ft.created_at AS transaction_date,
    (date_trunc('day'::text, ft.created_at))::date AS transaction_day,
    (date_trunc('month'::text, ft.created_at))::date AS transaction_month,
    (date_trunc('year'::text, ft.created_at))::date AS transaction_year,
    ft.transaction_type,
    ft.status AS transaction_status,
    ft.amount AS transaction_amount,
    ft.currency,
    ft.stripe_transaction_id,
    ft.payment_method,
    ft.description,
    ft.processed_at,
    b.booking_reference,
    b.booking_status,
    b.booking_date,
    b.start_time,
    b.total_amount AS booking_total_amount,
    b.service_fee AS booking_service_fee,
    b.remaining_balance AS booking_remaining_balance,
    b.payment_status,
    bp.id AS business_id,
    bp.business_name,
    cp.id AS customer_id,
    cp.first_name AS customer_first_name,
    cp.last_name AS customer_last_name,
    concat(cp.first_name, ' ', cp.last_name) AS customer_name,
    cp.email AS customer_email,
    s.id AS service_id,
    s.name AS service_name,
        CASE
            WHEN (ft.transaction_type = 'booking_payment'::transaction_type) THEN COALESCE(b.service_fee, ((ft.amount / 1.2) * 0.2))
            WHEN (ft.transaction_type = 'tip'::transaction_type) THEN (0)::numeric
            ELSE (0)::numeric
        END AS platform_fee_amount,
        CASE
            WHEN (ft.transaction_type = 'booking_payment'::transaction_type) THEN (ft.amount - COALESCE(b.service_fee, ((ft.amount / 1.2) * 0.2)))
            WHEN (ft.transaction_type = 'tip'::transaction_type) THEN (0)::numeric
            ELSE ft.amount
        END AS net_amount,
    bpt.id AS business_payment_transaction_id,
    bpt.payment_date AS business_payment_date,
    bpt.gross_payment_amount AS business_gross_amount,
    bpt.platform_fee AS business_platform_fee,
    bpt.net_payment_amount AS business_net_amount,
    bpt.transaction_type AS business_transaction_type,
    bpt.stripe_transfer_id,
    bpt.stripe_connect_account_id,
    t.id AS tip_id,
    t.tip_amount,
    t.provider_id AS tip_provider_id,
    t.payment_status AS tip_status,
    p.first_name AS provider_first_name,
    p.last_name AS provider_last_name,
    concat(p.first_name, ' ', p.last_name) AS provider_name
   FROM (((((((financial_transactions ft
     LEFT JOIN bookings b ON ((ft.booking_id = b.id)))
     LEFT JOIN business_profiles bp ON ((b.business_id = bp.id)))
     LEFT JOIN customer_profiles cp ON ((b.customer_id = cp.id)))
     LEFT JOIN services s ON ((b.service_id = s.id)))
     LEFT JOIN business_payment_transactions bpt ON (((ft.booking_id = bpt.booking_id) AND ((ft.stripe_transaction_id)::text = bpt.stripe_payment_intent_id))))
     LEFT JOIN tips t ON (((ft.booking_id = t.booking_id) AND (ft.transaction_type = 'tip'::transaction_type))))
     LEFT JOIN providers p ON ((t.provider_id = p.id)))
  WHERE (ft.status = 'completed'::status)
  ORDER BY ft.created_at DESC;


create or replace view "public"."admin_financial_summary" as  SELECT (date_trunc('day'::text, transaction_date))::date AS summary_date,
    (date_trunc('month'::text, transaction_date))::date AS summary_month,
    (date_trunc('year'::text, transaction_date))::date AS summary_year,
    count(*) AS total_transactions,
    count(DISTINCT booking_id) AS total_bookings,
    count(DISTINCT business_id) AS total_businesses,
    count(DISTINCT customer_id) AS total_customers,
    sum(transaction_amount) AS total_revenue,
    sum(platform_fee_amount) AS total_platform_fees,
    sum(net_amount) AS total_net_amount,
    sum(transaction_amount) FILTER (WHERE (transaction_type = 'booking_payment'::transaction_type)) AS booking_revenue,
    sum(transaction_amount) FILTER (WHERE (transaction_type = 'tip'::transaction_type)) AS tip_revenue,
    sum(transaction_amount) FILTER (WHERE (transaction_type = 'refund'::transaction_type)) AS refund_amount,
    sum(platform_fee_amount) FILTER (WHERE (transaction_type = 'booking_payment'::transaction_type)) AS booking_platform_fees,
    sum(net_amount) FILTER (WHERE (transaction_type = 'booking_payment'::transaction_type)) AS booking_net_amount,
    count(*) FILTER (WHERE (transaction_type = 'booking_payment'::transaction_type)) AS booking_transaction_count,
    count(*) FILTER (WHERE (transaction_type = 'tip'::transaction_type)) AS tip_transaction_count,
    count(*) FILTER (WHERE (transaction_type = 'refund'::transaction_type)) AS refund_count,
    avg(transaction_amount) AS avg_transaction_amount,
    avg(platform_fee_amount) AS avg_platform_fee,
    avg(net_amount) AS avg_net_amount
   FROM admin_financial_overview
  GROUP BY (date_trunc('day'::text, transaction_date)), (date_trunc('month'::text, transaction_date)), (date_trunc('year'::text, transaction_date))
  ORDER BY ((date_trunc('day'::text, transaction_date))::date) DESC;


create or replace view "public"."admin_service_reports_view" as  SELECT s.id,
    s.name AS service_name,
    s.description,
    s.min_price,
    s.duration_minutes,
    s.is_active,
    s.is_featured,
    s.is_popular,
    s.created_at,
    bs.business_price,
    bs.business_duration_minutes,
    bs.delivery_type,
    bs.is_active AS business_service_active,
    bp.id AS business_id,
    bp.business_name,
    ss.service_subcategory_type AS subcategory,
    sc.service_category_type AS category,
    COALESCE(booking_stats.total_bookings, (0)::bigint) AS total_bookings,
    COALESCE(booking_stats.completed_bookings, (0)::bigint) AS completed_bookings,
    COALESCE(booking_stats.total_revenue, (0)::numeric) AS total_revenue,
    COALESCE(booking_stats.completed_revenue, (0)::numeric) AS completed_revenue,
    COALESCE(booking_stats.avg_booking_amount, (0)::numeric) AS avg_booking_amount,
    COALESCE(rating_stats.avg_rating, (0)::numeric) AS avg_rating,
    COALESCE(rating_stats.total_reviews, (0)::bigint) AS total_reviews,
    COALESCE(rating_stats.approved_reviews, (0)::bigint) AS approved_reviews
   FROM ((((((services s
     JOIN business_services bs ON ((s.id = bs.service_id)))
     JOIN business_profiles bp ON ((bs.business_id = bp.id)))
     LEFT JOIN service_subcategories ss ON ((s.subcategory_id = ss.id)))
     LEFT JOIN service_categories sc ON ((ss.category_id = sc.id)))
     LEFT JOIN LATERAL ( SELECT count(DISTINCT b.id) AS total_bookings,
            count(DISTINCT b.id) FILTER (WHERE (b.booking_status = 'completed'::booking_status)) AS completed_bookings,
            sum(b.total_amount) AS total_revenue,
            sum(b.total_amount) FILTER (WHERE (b.booking_status = 'completed'::booking_status)) AS completed_revenue,
            avg(b.total_amount) FILTER (WHERE (b.booking_status = 'completed'::booking_status)) AS avg_booking_amount
           FROM bookings b
          WHERE (b.service_id = s.id)) booking_stats ON (true))
     LEFT JOIN LATERAL ( SELECT avg(r.overall_rating) AS avg_rating,
            count(r.id) AS total_reviews,
            count(r.id) FILTER (WHERE (r.is_approved = true)) AS approved_reviews
           FROM (reviews r
             JOIN bookings b ON ((r.booking_id = b.id)))
          WHERE (b.service_id = s.id)) rating_stats ON (true));


create or replace view "public"."admin_user_reports_view" as  SELECT u.id,
    u.email,
    u.created_at AS registration_date,
    u.last_sign_in_at AS last_activity,
    COALESCE(u.last_sign_in_at, u.created_at) AS last_activity_fallback,
        CASE
            WHEN (cp.id IS NOT NULL) THEN 'customer'::text
            WHEN (p.id IS NOT NULL) THEN
            CASE
                WHEN (p.provider_role = 'owner'::provider_role) THEN 'business'::text
                ELSE 'provider'::text
            END
            ELSE 'unknown'::text
        END AS user_type,
        CASE
            WHEN (cp.id IS NOT NULL) THEN COALESCE(cp.is_active, true)
            WHEN (p.id IS NOT NULL) THEN COALESCE(p.is_active, true)
            ELSE false
        END AS is_active_flag,
        CASE
            WHEN ((cp.id IS NOT NULL) AND (NOT COALESCE(cp.is_active, true))) THEN 'inactive'::text
            WHEN ((p.id IS NOT NULL) AND (NOT COALESCE(p.is_active, true))) THEN 'inactive'::text
            ELSE 'active'::text
        END AS status,
    cp.first_name AS customer_first_name,
    cp.last_name AS customer_last_name,
    cp.phone AS customer_phone,
    cl.city AS customer_city,
    cl.state AS customer_state,
    cl.zip_code AS customer_zip_code,
        CASE
            WHEN ((cl.city IS NOT NULL) AND (cl.state IS NOT NULL)) THEN concat(cl.city, ', ', cl.state, COALESCE((' '::text || (cl.zip_code)::text), ''::text))
            ELSE NULL::text
        END AS customer_location,
    p.first_name AS provider_first_name,
    p.last_name AS provider_last_name,
    p.phone AS provider_phone,
    p.provider_role,
    p.business_id AS provider_business_id,
    bp.business_name,
    bl.city AS business_city,
    bl.state AS business_state,
    bl.postal_code AS business_postal_code,
        CASE
            WHEN ((bl.city IS NOT NULL) AND (bl.state IS NOT NULL)) THEN concat(bl.city, ', ', bl.state, COALESCE((' '::text || (bl.postal_code)::text), ''::text))
            ELSE NULL::text
        END AS business_location,
    COALESCE(
        CASE
            WHEN ((cl.city IS NOT NULL) AND (cl.state IS NOT NULL)) THEN concat(cl.city, ', ', cl.state, COALESCE((' '::text || (cl.zip_code)::text), ''::text))
            ELSE NULL::text
        END,
        CASE
            WHEN ((bl.city IS NOT NULL) AND (bl.state IS NOT NULL)) THEN concat(bl.city, ', ', bl.state, COALESCE((' '::text || (bl.postal_code)::text), ''::text))
            ELSE NULL::text
        END, 'Unknown'::text) AS location,
    COALESCE(( SELECT count(DISTINCT b.id) AS count
           FROM bookings b
          WHERE (b.customer_id = cp.id)), (0)::bigint) AS total_bookings,
    COALESCE(( SELECT sum(b.total_amount) AS sum
           FROM bookings b
          WHERE (b.customer_id = cp.id)), (0)::numeric) AS total_spent,
    COALESCE(( SELECT count(DISTINCT b.id) AS count
           FROM bookings b
          WHERE (b.provider_id = p.id)), (0)::bigint) AS provider_total_bookings,
    COALESCE(( SELECT sum(b.total_amount) AS sum
           FROM bookings b
          WHERE (b.provider_id = p.id)), (0)::numeric) AS total_earned,
    COALESCE(( SELECT avg(r.overall_rating) AS avg
           FROM (reviews r
             JOIN bookings b ON ((r.booking_id = b.id)))
          WHERE (b.customer_id = cp.id)), (0)::numeric) AS customer_avg_rating,
    COALESCE(( SELECT count(r.id) AS count
           FROM (reviews r
             JOIN bookings b ON ((r.booking_id = b.id)))
          WHERE (b.customer_id = cp.id)), (0)::bigint) AS customer_total_reviews,
    COALESCE(( SELECT avg(r.overall_rating) AS avg
           FROM reviews r
          WHERE (r.provider_id = p.id)), (0)::numeric) AS provider_avg_rating,
    COALESCE(( SELECT count(r.id) AS count
           FROM reviews r
          WHERE (r.provider_id = p.id)), (0)::bigint) AS provider_total_reviews,
    COALESCE(( SELECT avg(r.overall_rating) AS avg
           FROM (reviews r
             JOIN bookings b ON ((r.booking_id = b.id)))
          WHERE (b.customer_id = cp.id)), ( SELECT avg(r.overall_rating) AS avg
           FROM reviews r
          WHERE (r.provider_id = p.id)), (0)::numeric) AS avg_rating,
    COALESCE(( SELECT count(r.id) AS count
           FROM (reviews r
             JOIN bookings b ON ((r.booking_id = b.id)))
          WHERE (b.customer_id = cp.id)), ( SELECT count(r.id) AS count
           FROM reviews r
          WHERE (r.provider_id = p.id)), (0)::bigint) AS total_reviews
   FROM (((((auth.users u
     LEFT JOIN customer_profiles cp ON ((u.id = cp.user_id)))
     LEFT JOIN customer_locations cl ON (((u.id = cl.customer_id) AND (cl.is_primary = true))))
     LEFT JOIN providers p ON ((u.id = p.user_id)))
     LEFT JOIN business_profiles bp ON ((p.business_id = bp.id)))
     LEFT JOIN business_locations bl ON (((bp.id = bl.business_id) AND (bl.is_primary = true))));


create or replace view "public"."business_earnings_by_period" as  SELECT business_id,
    date_trunc('day'::text, (payment_date)::timestamp with time zone) AS period_date,
    date_trunc('month'::text, (payment_date)::timestamp with time zone) AS period_month,
    date_trunc('year'::text, (payment_date)::timestamp with time zone) AS period_year,
    tax_year,
    count(*) AS transaction_count,
    count(DISTINCT booking_id) AS booking_count,
    sum(gross_payment_amount) AS gross_earnings,
    sum(platform_fee) AS platform_fees,
    sum(net_payment_amount) AS net_earnings,
    count(*) FILTER (WHERE (transaction_type = 'initial_booking'::business_payment_transaction_type)) AS initial_bookings,
    count(*) FILTER (WHERE (transaction_type = 'additional_service'::business_payment_transaction_type)) AS additional_services
   FROM business_payment_transactions
  GROUP BY business_id, (date_trunc('day'::text, (payment_date)::timestamp with time zone)), (date_trunc('month'::text, (payment_date)::timestamp with time zone)), (date_trunc('year'::text, (payment_date)::timestamp with time zone)), tax_year;


create or replace view "public"."business_earnings_by_service" as  SELECT bpt.business_id,
    b.service_id,
    s.name AS service_name,
    count(DISTINCT bpt.booking_id) AS booking_count,
    count(*) AS transaction_count,
    sum(bpt.gross_payment_amount) AS total_gross_earnings,
    sum(bpt.platform_fee) AS total_platform_fees,
    sum(bpt.net_payment_amount) AS total_net_earnings,
    avg(bpt.gross_payment_amount) AS avg_gross_per_transaction,
    avg(bpt.net_payment_amount) AS avg_net_per_transaction,
    min(bpt.payment_date) AS first_payment_date,
    max(bpt.payment_date) AS last_payment_date
   FROM ((business_payment_transactions bpt
     JOIN bookings b ON ((bpt.booking_id = b.id)))
     LEFT JOIN services s ON ((b.service_id = s.id)))
  GROUP BY bpt.business_id, b.service_id, s.name;


create or replace view "public"."business_earnings_detailed" as  SELECT bpt.id,
    bpt.business_id,
    bpt.booking_id,
    bpt.payment_date,
    bpt.gross_payment_amount,
    bpt.platform_fee,
    bpt.net_payment_amount,
    bpt.tax_year,
    bpt.transaction_type,
    bpt.stripe_payment_intent_id,
    bpt.stripe_transfer_id,
    bpt.stripe_connect_account_id,
    bpt.booking_reference,
    bpt.transaction_description,
    bpt.created_at,
    b.booking_date,
    b.booking_status,
    b.total_amount AS booking_total_amount,
    b.service_id,
    s.name AS service_name,
    s.min_price AS service_price,
    cp.first_name AS customer_first_name,
    cp.last_name AS customer_last_name
   FROM (((business_payment_transactions bpt
     LEFT JOIN bookings b ON ((bpt.booking_id = b.id)))
     LEFT JOIN services s ON ((b.service_id = s.id)))
     LEFT JOIN customer_profiles cp ON ((b.customer_id = cp.user_id)));


create or replace view "public"."business_earnings_summary" as  SELECT business_id,
    tax_year,
    count(*) AS total_transactions,
    count(DISTINCT booking_id) AS total_bookings,
    sum(gross_payment_amount) AS total_gross_earnings,
    sum(platform_fee) AS total_platform_fees,
    sum(net_payment_amount) AS total_net_earnings,
    min(payment_date) AS first_payment_date,
    max(payment_date) AS last_payment_date,
    count(*) FILTER (WHERE (transaction_type = 'initial_booking'::business_payment_transaction_type)) AS initial_booking_count,
    count(*) FILTER (WHERE (transaction_type = 'additional_service'::business_payment_transaction_type)) AS additional_service_count,
    sum(gross_payment_amount) FILTER (WHERE (transaction_type = 'initial_booking'::business_payment_transaction_type)) AS initial_booking_gross,
    sum(gross_payment_amount) FILTER (WHERE (transaction_type = 'additional_service'::business_payment_transaction_type)) AS additional_service_gross,
    sum(net_payment_amount) FILTER (WHERE (transaction_type = 'initial_booking'::business_payment_transaction_type)) AS initial_booking_net,
    sum(net_payment_amount) FILTER (WHERE (transaction_type = 'additional_service'::business_payment_transaction_type)) AS additional_service_net
   FROM business_payment_transactions
  GROUP BY business_id, tax_year;


create or replace view "public"."business_eligible_addons_enriched" as  SELECT DISTINCT ON (bss.business_id, sa.id) bss.business_id,
    sa.id AS addon_id,
    sa.name AS addon_name,
    sa.description AS addon_description,
    sa.image_url AS addon_image_url,
    sa.is_active AS addon_is_active,
    sae.service_id AS eligible_via_service_id,
    s.name AS eligible_via_service_name,
    sae.is_recommended,
    s.subcategory_id,
    sc.service_subcategory_type AS subcategory_name,
    sc.category_id,
    cat.service_category_type AS category_name,
    ba.id AS business_addon_id,
    ba.custom_price,
    ba.is_available,
        CASE
            WHEN (ba.id IS NOT NULL) THEN true
            ELSE false
        END AS is_configured,
    COALESCE(ba.is_available, false) AS is_business_available
   FROM (((((((business_service_subcategories bss
     JOIN service_subcategories sc ON (((bss.subcategory_id = sc.id) AND (sc.is_active = true))))
     JOIN service_categories cat ON (((sc.category_id = cat.id) AND (cat.is_active = true))))
     JOIN business_service_categories bsc ON (((bss.business_id = bsc.business_id) AND (sc.category_id = bsc.category_id) AND (bsc.is_active = true))))
     JOIN services s ON (((s.subcategory_id = sc.id) AND (s.is_active = true))))
     JOIN service_addon_eligibility sae ON ((sae.service_id = s.id)))
     JOIN service_addons sa ON (((sa.id = sae.addon_id) AND (sa.is_active = true))))
     LEFT JOIN business_addons ba ON (((ba.business_id = bss.business_id) AND (ba.addon_id = sa.id))))
  WHERE (bss.is_active = true);


create or replace view "public"."business_eligible_services_enriched" as  SELECT bss.business_id,
    s.id AS service_id,
    s.name AS service_name,
    s.description AS service_description,
    s.min_price,
    s.duration_minutes,
    s.image_url AS service_image_url,
    s.is_active AS service_is_active,
    s.subcategory_id,
    sc.service_subcategory_type AS subcategory_name,
    sc.description AS subcategory_description,
    sc.category_id,
    cat.service_category_type AS category_name,
    cat.description AS category_description,
    bs.id AS business_service_id,
    bs.business_price,
    bs.business_duration_minutes,
    bs.delivery_type,
    bs.is_active AS business_is_active,
    bs.created_at AS business_service_created_at,
        CASE
            WHEN (bs.id IS NOT NULL) THEN true
            ELSE false
        END AS is_configured,
    COALESCE(bs.is_active, false) AS is_business_active
   FROM (((((business_service_subcategories bss
     JOIN service_subcategories sc ON (((bss.subcategory_id = sc.id) AND (sc.is_active = true))))
     JOIN service_categories cat ON (((sc.category_id = cat.id) AND (cat.is_active = true))))
     JOIN business_service_categories bsc ON (((bss.business_id = bsc.business_id) AND (sc.category_id = bsc.category_id) AND (bsc.is_active = true))))
     JOIN services s ON (((s.subcategory_id = sc.id) AND (s.is_active = true))))
     LEFT JOIN business_services bs ON (((bs.business_id = bss.business_id) AND (bs.service_id = s.id))))
  WHERE (bss.is_active = true);


create or replace view "public"."business_monthly_earnings" as  SELECT business_id,
    tax_year,
    (date_trunc('month'::text, (payment_date)::timestamp with time zone))::date AS month_start,
    to_char(date_trunc('month'::text, (payment_date)::timestamp with time zone), 'YYYY-MM'::text) AS month_key,
    count(*) AS transaction_count,
    count(DISTINCT booking_id) AS booking_count,
    sum(gross_payment_amount) AS gross_earnings,
    sum(platform_fee) AS platform_fees,
    sum(net_payment_amount) AS net_earnings
   FROM business_payment_transactions
  GROUP BY business_id, tax_year, (date_trunc('month'::text, (payment_date)::timestamp with time zone));


CREATE OR REPLACE FUNCTION public.can_write_business_file(p_business_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles ur
    WHERE ur.user_id = auth.uid()
      AND ur.business_id = p_business_id
      AND ur.is_active = true
      AND ur.role IN ('owner','dispatcher','admin','provider')
  );
$function$
;

CREATE OR REPLACE FUNCTION public.check_business_price_above_minimum()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Check if the business price is at least equal to the minimum price of the service
  IF NEW.business_price < (SELECT min_price FROM public.services WHERE id = NEW.service_id) THEN
    RAISE EXCEPTION 'Business price cannot be lower than the service minimum price';
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.cleanup_expired_mfa_challenges()
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM public.mfa_challenges 
    WHERE expires_at < NOW();
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.cleanup_expired_mfa_sessions()
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM public.mfa_sessions 
    WHERE expires_at < NOW();
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.current_user_has_role(role_name text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  return exists (
    select 1 from public.user_roles
    where user_roles.user_id = auth.uid()
    and user_roles.role = role_name
  );
end;
$function$
;

create or replace view "public"."customer_favorite_businesses_view" as  SELECT cfb.id,
    cfb.customer_id,
    cfb.business_id,
    cfb.created_at,
    bp.business_name,
    bp.image_url,
    bp.logo_url,
    bp.cover_image_url,
    bp.business_type,
    bp.service_categories,
    bp.service_subcategories,
    bp.verification_status
   FROM (customer_favorite_businesses cfb
     JOIN business_profiles bp ON ((cfb.business_id = bp.id)))
  WHERE (bp.is_active = true);


create or replace view "public"."customer_favorite_providers_view" as  SELECT cfp.id,
    cfp.customer_id,
    cfp.provider_id,
    cfp.created_at,
    p.first_name,
    p.last_name,
    p.image_url,
    p.bio,
    p.experience_years,
    p.average_rating,
    p.total_reviews,
    p.business_id,
    bp.business_name
   FROM ((customer_favorite_providers cfp
     JOIN providers p ON ((cfp.provider_id = p.id)))
     LEFT JOIN business_profiles bp ON ((p.business_id = bp.id)))
  WHERE (p.is_active = true);


create or replace view "public"."customer_favorite_services_view" as  SELECT cfs.id,
    cfs.customer_id,
    cfs.service_id,
    cfs.created_at,
    s.name AS service_name,
    s.description AS service_description,
    s.min_price,
    s.duration_minutes,
    s.image_url,
    sc.service_category_type,
    ss.service_subcategory_type
   FROM (((customer_favorite_services cfs
     JOIN services s ON ((cfs.service_id = s.id)))
     JOIN service_subcategories ss ON ((s.subcategory_id = ss.id)))
     JOIN service_categories sc ON ((ss.category_id = sc.id)))
  WHERE (s.is_active = true);


CREATE OR REPLACE FUNCTION public.customer_has_location()
 RETURNS boolean
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
DECLARE
    customer_id_var UUID;
    has_location BOOLEAN;
BEGIN
    -- Get the customer_id for the current user
    SELECT id INTO customer_id_var 
    FROM public.customer_profiles 
    WHERE user_id = auth.uid();
    
    IF customer_id_var IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Check if customer has at least one location
    SELECT EXISTS (
        SELECT 1 
        FROM public.customer_locations 
        WHERE customer_id = customer_id_var
    ) INTO has_location;
    
    RETURN has_location;
END;
$function$
;

create or replace view "public"."eligible_provider_tips" as  SELECT t.id,
    t.booking_id,
    t.customer_id,
    t.provider_id,
    t.business_id,
    t.tip_amount,
    t.tip_percentage,
    t.stripe_payment_intent_id,
    t.payment_status,
    t.platform_fee_amount,
    t.provider_net_amount,
    t.customer_message,
    t.provider_response,
    t.provider_responded_at,
    t.tip_given_at,
    t.payment_processed_at,
    t.payout_status,
    t.payout_batch_id,
    t.payout_date,
    t.created_at,
    t.updated_at,
    p.first_name AS provider_first_name,
    p.last_name AS provider_last_name,
    p.provider_role,
    cp.first_name AS customer_first_name,
    cp.last_name AS customer_last_name,
    b.booking_reference,
    b.booking_date,
    b.start_time,
    b.booking_status,
    s.name AS service_name
   FROM ((((tips t
     JOIN providers p ON ((t.provider_id = p.id)))
     JOIN bookings b ON ((t.booking_id = b.id)))
     LEFT JOIN customer_profiles cp ON ((t.customer_id = cp.id)))
     LEFT JOIN services s ON ((b.service_id = s.id)))
  WHERE ((p.is_active = true) AND (p.active_for_bookings = true) AND (p.business_id = t.business_id));


CREATE OR REPLACE FUNCTION public.ensure_customer_default_location()
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
    customer_id_var UUID;
    location_id_var UUID;
    user_id_var UUID;
    user_meta JSONB;
    address_line1 TEXT;
    address_line2 TEXT;
    city TEXT;
    state TEXT;
    postal_code TEXT;
    country TEXT;
BEGIN
    -- Get the current user's ID
    user_id_var := auth.uid();
    
    IF user_id_var IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;
    
    -- Ensure customer profile exists and get ID
    customer_id_var := public.ensure_customer_profile();
    
    -- Check if customer already has a location
    SELECT id INTO location_id_var 
    FROM public.customer_locations 
    WHERE customer_id = customer_id_var
    ORDER BY is_default DESC, created_at DESC
    LIMIT 1;
    
    -- If location exists, return its ID
    IF location_id_var IS NOT NULL THEN
        RETURN location_id_var;
    END IF;
    
    -- Get user metadata for location info
    SELECT raw_user_meta_data INTO user_meta
    FROM auth.users
    WHERE id = user_id_var;
    
    -- Extract location data from user metadata if available
    address_line1 := user_meta->>'address_line1';
    address_line2 := user_meta->>'address_line2';
    city := user_meta->>'city';
    state := user_meta->>'state';
    postal_code := user_meta->>'postal_code';
    country := user_meta->>'country';
    
    -- Create a default location with available info
    INSERT INTO public.customer_locations (
        customer_id,
        name,
        address_line1,
        address_line2,
        city,
        state,
        postal_code,
        country,
        is_default,
        created_at,
        updated_at
    ) VALUES (
        customer_id_var,
        'Default Location',
        COALESCE(address_line1, ''),
        COALESCE(address_line2, ''),
        COALESCE(city, ''),
        COALESCE(state, ''),
        COALESCE(postal_code, ''),
        COALESCE(country, 'US'),
        TRUE,
        NOW(),
        NOW()
    )
    RETURNING id INTO location_id_var;
    
    RETURN location_id_var;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.ensure_customer_profile()
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
    user_id_var UUID;
    customer_id_var UUID;
    user_email TEXT;
    user_first_name TEXT;
    user_last_name TEXT;
BEGIN
    -- Get the current user's ID
    user_id_var := auth.uid();
    
    IF user_id_var IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;
    
    -- Check if customer profile already exists
    SELECT id INTO customer_id_var 
    FROM public.customer_profiles 
    WHERE user_id = user_id_var;
    
    -- If customer profile exists, return its ID
    IF customer_id_var IS NOT NULL THEN
        RETURN customer_id_var;
    END IF;
    
    -- Get user details from auth.users
    SELECT 
        email,
        (raw_user_meta_data->>'first_name'),
        (raw_user_meta_data->>'last_name')
    INTO 
        user_email,
        user_first_name,
        user_last_name
    FROM auth.users
    WHERE id = user_id_var;
    
    -- Create a new customer profile
    INSERT INTO public.customer_profiles (
        user_id,
        email,
        first_name,
        last_name,
        created_at,
        updated_at
    ) VALUES (
        user_id_var,
        user_email,
        COALESCE(user_first_name, ''),
        COALESCE(user_last_name, ''),
        NOW(),
        NOW()
    )
    RETURNING id INTO customer_id_var;
    
    RETURN customer_id_var;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.generate_booking_reference()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
DECLARE
  new_reference TEXT;
  prefix TEXT := 'BK';
  random_chars TEXT;
  year_suffix TEXT;
  counter INT;
BEGIN
  -- Get current year (last 2 digits)
  year_suffix := to_char(CURRENT_DATE, 'YY');
  
  -- Generate random alphanumeric characters (4 characters)
  random_chars := array_to_string(ARRAY(
    SELECT substr('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', trunc(random() * 31 + 1)::integer, 1)
    FROM generate_series(1, 4)
  ), '');
  
  -- Get a sequential counter (last 4 digits, reset each day)
  SELECT COALESCE(MAX(SUBSTRING(booking_reference FROM 9)::integer), 0) + 1 
  INTO counter
  FROM public.bookings
  WHERE booking_reference LIKE prefix || year_suffix || random_chars || '%';
  
  -- Format the counter with leading zeros
  new_reference := prefix || year_suffix || random_chars || LPAD(counter::text, 4, '0');
  
  -- Assign the generated reference to the new booking
  NEW.booking_reference := new_reference;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_business_addon_counts(p_business_id uuid)
 RETURNS TABLE(total_eligible bigint, available bigint, configured bigint, unconfigured bigint)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*) AS total_eligible,
    COUNT(*) FILTER (WHERE is_business_available = true) AS available,
    COUNT(*) FILTER (WHERE is_configured = true) AS configured,
    COUNT(*) FILTER (WHERE is_configured = false) AS unconfigured
  FROM business_eligible_addons_enriched
  WHERE business_id = p_business_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_business_eligible_addons_optimized(p_business_id uuid, p_search text DEFAULT NULL::text, p_status text DEFAULT NULL::text, p_limit integer DEFAULT 50, p_offset integer DEFAULT 0)
 RETURNS TABLE(addons jsonb, total_count bigint, stats jsonb)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_addons JSONB;
  v_total_count BIGINT;
  v_stats JSONB;
BEGIN
  -- Build the filtered results
  WITH filtered_addons AS (
    SELECT *
    FROM business_eligible_addons_enriched bea
    WHERE bea.business_id = p_business_id
      -- Search filter
      AND (
        p_search IS NULL 
        OR p_search = ''
        OR bea.addon_name ILIKE '%' || p_search || '%'
        OR bea.addon_description ILIKE '%' || p_search || '%'
        OR bea.subcategory_name ILIKE '%' || p_search || '%'
      )
      -- Status filter
      AND (
        p_status IS NULL
        OR p_status = 'all'
        OR (p_status = 'available' AND bea.is_business_available = true)
        OR (p_status = 'unavailable' AND bea.is_business_available = false)
        OR (p_status = 'configured' AND bea.is_configured = true)
        OR (p_status = 'unconfigured' AND bea.is_configured = false)
      )
  ),
  -- Calculate stats from filtered results
  addon_stats AS (
    SELECT
      COUNT(*) AS total_addons,
      COUNT(*) FILTER (WHERE is_business_available = true) AS available_addons,
      COUNT(*) FILTER (WHERE is_configured = true) AS configured_addons,
      COUNT(*) FILTER (WHERE is_configured = false) AS unconfigured_addons,
      COALESCE(AVG(custom_price) FILTER (WHERE is_business_available = true AND custom_price IS NOT NULL), 0) AS avg_price,
      COALESCE(SUM(custom_price) FILTER (WHERE is_business_available = true AND custom_price IS NOT NULL), 0) AS total_value
    FROM filtered_addons
  ),
  -- Paginate results
  paginated_addons AS (
    SELECT *
    FROM filtered_addons
    ORDER BY addon_name
    LIMIT p_limit
    OFFSET p_offset
  )
  SELECT 
    COALESCE(
      (SELECT jsonb_agg(
        jsonb_build_object(
          'id', pa.addon_id,
          'name', pa.addon_name,
          'description', pa.addon_description,
          'image_url', pa.addon_image_url,
          'is_active', pa.addon_is_active,
          'subcategory_id', pa.subcategory_id,
          'subcategory_name', pa.subcategory_name,
          'category_name', pa.category_name,
          'is_configured', pa.is_configured,
          'business_addon_id', pa.business_addon_id,
          'custom_price', pa.custom_price,
          'is_available', pa.is_business_available,
          'eligible_via_service', pa.eligible_via_service_name,
          'is_recommended', pa.is_recommended
        )
      ) FROM paginated_addons pa),
      '[]'::jsonb
    ),
    (SELECT COUNT(*) FROM filtered_addons),
    (SELECT jsonb_build_object(
      'total_addons', as_stats.total_addons,
      'available_addons', as_stats.available_addons,
      'configured_addons', as_stats.configured_addons,
      'unconfigured_addons', as_stats.unconfigured_addons,
      'avg_price', ROUND(as_stats.avg_price::numeric, 2),
      'total_value', ROUND(as_stats.total_value::numeric, 2)
    ) FROM addon_stats as_stats)
  INTO v_addons, v_total_count, v_stats;

  RETURN QUERY SELECT v_addons, v_total_count, v_stats;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_business_eligible_services_optimized(p_business_id uuid, p_search text DEFAULT NULL::text, p_status text DEFAULT NULL::text, p_category_id uuid DEFAULT NULL::uuid, p_subcategory_id uuid DEFAULT NULL::uuid, p_limit integer DEFAULT 50, p_offset integer DEFAULT 0)
 RETURNS TABLE(services jsonb, total_count bigint, stats jsonb)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_services JSONB;
  v_total_count BIGINT;
  v_stats JSONB;
BEGIN
  -- Build the filtered results
  WITH filtered_services AS (
    SELECT *
    FROM business_eligible_services_enriched bes
    WHERE bes.business_id = p_business_id
      -- Search filter
      AND (
        p_search IS NULL 
        OR p_search = ''
        OR bes.service_name ILIKE '%' || p_search || '%'
        OR bes.service_description ILIKE '%' || p_search || '%'
        OR bes.category_name ILIKE '%' || p_search || '%'
        OR bes.subcategory_name ILIKE '%' || p_search || '%'
      )
      -- Status filter
      AND (
        p_status IS NULL
        OR p_status = 'all'
        OR (p_status = 'active' AND bes.is_business_active = true)
        OR (p_status = 'inactive' AND bes.is_business_active = false)
        OR (p_status = 'configured' AND bes.is_configured = true)
        OR (p_status = 'unconfigured' AND bes.is_configured = false)
      )
      -- Category filter
      AND (p_category_id IS NULL OR bes.category_id = p_category_id)
      -- Subcategory filter
      AND (p_subcategory_id IS NULL OR bes.subcategory_id = p_subcategory_id)
  ),
  -- Calculate stats from filtered results
  service_stats AS (
    SELECT
      COUNT(*) AS total_services,
      COUNT(*) FILTER (WHERE is_business_active = true) AS active_services,
      COUNT(*) FILTER (WHERE is_configured = true) AS configured_services,
      COUNT(*) FILTER (WHERE is_configured = false) AS unconfigured_services,
      COALESCE(AVG(COALESCE(business_price, min_price)) FILTER (WHERE is_business_active = true), 0) AS avg_price,
      COALESCE(SUM(COALESCE(business_price, min_price)) FILTER (WHERE is_business_active = true), 0) AS total_value,
      COUNT(DISTINCT category_id) AS category_count,
      COUNT(DISTINCT subcategory_id) AS subcategory_count
    FROM filtered_services
  ),
  -- Paginate results
  paginated_services AS (
    SELECT *
    FROM filtered_services
    ORDER BY category_name, subcategory_name, service_name
    LIMIT p_limit
    OFFSET p_offset
  )
  SELECT 
    COALESCE(
      (SELECT jsonb_agg(
        jsonb_build_object(
          'id', ps.service_id,
          'name', ps.service_name,
          'description', ps.service_description,
          'min_price', ps.min_price,
          'duration_minutes', ps.duration_minutes,
          'image_url', ps.service_image_url,
          'subcategory_id', ps.subcategory_id,
          'subcategory_name', ps.subcategory_name,
          'category_id', ps.category_id,
          'category_name', ps.category_name,
          'is_configured', ps.is_configured,
          'business_service_id', ps.business_service_id,
          'business_price', ps.business_price,
          'business_duration_minutes', ps.business_duration_minutes,
          'delivery_type', ps.delivery_type,
          'business_is_active', ps.is_business_active,
          'service_subcategories', jsonb_build_object(
            'id', ps.subcategory_id,
            'service_subcategory_type', ps.subcategory_name,
            'service_categories', jsonb_build_object(
              'id', ps.category_id,
              'service_category_type', ps.category_name
            )
          )
        )
      ) FROM paginated_services ps),
      '[]'::jsonb
    ),
    (SELECT COUNT(*) FROM filtered_services),
    (SELECT jsonb_build_object(
      'total_services', ss.total_services,
      'active_services', ss.active_services,
      'configured_services', ss.configured_services,
      'unconfigured_services', ss.unconfigured_services,
      'avg_price', ROUND(ss.avg_price::numeric, 2),
      'total_value', ROUND(ss.total_value::numeric, 2),
      'category_count', ss.category_count,
      'subcategory_count', ss.subcategory_count
    ) FROM service_stats ss)
  INTO v_services, v_total_count, v_stats;

  RETURN QUERY SELECT v_services, v_total_count, v_stats;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_business_service_counts(p_business_id uuid)
 RETURNS TABLE(total_eligible bigint, active bigint, configured bigint, unconfigured bigint)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*) AS total_eligible,
    COUNT(*) FILTER (WHERE is_business_active = true) AS active,
    COUNT(*) FILTER (WHERE is_configured = true) AS configured,
    COUNT(*) FILTER (WHERE is_configured = false) AS unconfigured
  FROM business_eligible_services_enriched
  WHERE business_id = p_business_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_conversation_counts(p_user_id uuid, p_user_type text, p_business_id uuid DEFAULT NULL::uuid)
 RETURNS TABLE(total_conversations bigint, unread_conversations bigint, total_unread_messages bigint)
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
  WITH user_conversations AS (
    SELECT DISTINCT cm.id
    FROM conversation_metadata cm
    JOIN conversation_participants cp ON cp.conversation_id = cm.id
    WHERE cp.user_id = p_user_id
      AND cp.is_active = true
      AND cm.is_active = true
      AND (
        (p_user_type IN ('provider', 'owner', 'dispatcher') AND cp.user_type IN ('provider', 'owner', 'dispatcher'))
        OR
        (p_user_type = 'customer' AND cp.user_type = 'customer')
      )
  ),
  unread_stats AS (
    SELECT 
      COUNT(DISTINCT mn.conversation_id) as unread_convs,
      COUNT(*) as unread_msgs
    FROM message_notifications mn
    JOIN user_conversations uc ON mn.conversation_id = uc.id
    WHERE mn.user_id = p_user_id AND mn.is_read = false
  )
  SELECT 
    (SELECT COUNT(*) FROM user_conversations)::BIGINT,
    COALESCE(us.unread_convs, 0)::BIGINT,
    COALESCE(us.unread_msgs, 0)::BIGINT
  FROM unread_stats us;
$function$
;

CREATE OR REPLACE FUNCTION public.get_current_user_roles()
 RETURNS TABLE(role text)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  return query
    select user_roles.role
    from public.user_roles
    where user_roles.user_id = auth.uid();
end;
$function$
;

CREATE OR REPLACE FUNCTION public.get_customer_bookings_with_relations(p_customer_id uuid, p_limit integer DEFAULT 50, p_offset integer DEFAULT 0)
 RETURNS TABLE(id uuid, customer_id uuid, provider_id uuid, service_id uuid, booking_date date, start_time time without time zone, total_amount numeric, service_fee numeric, remaining_balance numeric, created_at timestamp with time zone, booking_status text, payment_status text, delivery_type text, business_id uuid, booking_reference text, provider_first_name text, provider_last_name text, provider_email text, provider_phone text, provider_image_url text, provider_business_id uuid, provider_average_rating numeric, service_name text, service_description text, service_price numeric, service_duration integer, customer_first_name text, customer_last_name text, customer_email text, customer_phone text)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
  SELECT 
    b.id,
    b.customer_id,
    b.provider_id,
    b.service_id,
    b.booking_date,
    b.start_time,
    b.total_amount,
    b.service_fee,
    b.remaining_balance,
    b.created_at,
    b.booking_status::TEXT,
    b.payment_status::TEXT,
    b.delivery_type::TEXT,
    b.business_id,
    b.booking_reference,
    -- Provider fields
    p.first_name AS provider_first_name,
    p.last_name AS provider_last_name,
    p.email AS provider_email,
    p.phone AS provider_phone,
    p.image_url AS provider_image_url,
    p.business_id AS provider_business_id,
    p.average_rating AS provider_average_rating,
    -- Service fields
    s.name AS service_name,
    s.description AS service_description,
    s.min_price AS service_price,
    s.duration_minutes AS service_duration,
    -- Customer fields
    cp.first_name AS customer_first_name,
    cp.last_name AS customer_last_name,
    cp.email AS customer_email,
    cp.phone AS customer_phone
  FROM public.bookings b
  LEFT JOIN public.providers p ON b.provider_id = p.id
  LEFT JOIN public.services s ON b.service_id = s.id
  LEFT JOIN public.customer_profiles cp ON b.customer_id = cp.id
  WHERE b.customer_id = p_customer_id
  ORDER BY b.booking_date DESC, b.start_time DESC
  LIMIT p_limit
  OFFSET p_offset;
$function$
;

CREATE OR REPLACE FUNCTION public.get_provider_available_slots(p_provider_id uuid, p_date date, p_service_duration integer DEFAULT 60)
 RETURNS TABLE(slot_time time without time zone, is_available boolean, max_bookings integer, current_bookings integer)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  WITH availability_for_date AS (
    SELECT 
      pa.start_time,
      pa.end_time,
      pa.slot_duration_minutes,
      pa.max_bookings_per_slot,
      pa.buffer_time_minutes
    FROM public.provider_availability pa
    WHERE pa.provider_id = p_provider_id
      AND pa.is_active = true
      AND pa.is_blocked = false
      AND (
        -- Weekly recurring schedule matching the day
        (pa.schedule_type = 'weekly_recurring' AND pa.day_of_week = EXTRACT(DOW FROM p_date)) OR
        -- Specific date
        (pa.schedule_type = 'specific_date' AND pa.start_date = p_date) OR
        -- Date range
        (pa.schedule_type = 'date_range' AND p_date BETWEEN pa.start_date AND pa.end_date)
      )
      -- Check for exceptions
      AND NOT EXISTS (
        SELECT 1 FROM public.provider_availability_exceptions pae
        WHERE pae.provider_id = p_provider_id 
          AND pae.exception_date = p_date 
          AND pae.exception_type = 'unavailable'
      )
  ),
  time_slots AS (
    SELECT 
      (av.start_time + (slot_num * (av.slot_duration_minutes + av.buffer_time_minutes) * INTERVAL '1 minute'))::TIME as slot_time,
      av.max_bookings_per_slot
    FROM availability_for_date av
    CROSS JOIN generate_series(0, 
      EXTRACT(EPOCH FROM (av.end_time - av.start_time)) / 60 / (av.slot_duration_minutes + av.buffer_time_minutes)
    ) as slot_num
    WHERE (av.start_time + ((slot_num + 1) * av.slot_duration_minutes * INTERVAL '1 minute')) <= av.end_time
  ),
  existing_bookings AS (
    SELECT 
      date_trunc('hour', b.scheduled_date)::TIME as booking_time,
      COUNT(*) as booking_count
    FROM public.bookings b
    WHERE b.provider_id = (
        SELECT id FROM public.providers 
        WHERE id = p_provider_id
      )
      AND b.scheduled_date::DATE = p_date
      AND b.status NOT IN ('cancelled')
    GROUP BY date_trunc('hour', b.scheduled_date)::TIME
  )
  SELECT 
    ts.slot_time,
    CASE 
      WHEN COALESCE(eb.booking_count, 0) < ts.max_bookings_per_slot THEN true
      ELSE false
    END as is_available,
    ts.max_bookings_per_slot as max_bookings,
    COALESCE(eb.booking_count, 0)::INTEGER as current_bookings
  FROM time_slots ts
  LEFT JOIN existing_bookings eb ON ts.slot_time = eb.booking_time
  ORDER BY ts.slot_time;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_provider_booking_counts(p_business_id uuid, p_provider_id uuid DEFAULT NULL::uuid, p_date_from date DEFAULT NULL::date, p_date_to date DEFAULT NULL::date)
 RETURNS TABLE(present_count bigint, future_count bigint, past_count bigint, pending_count bigint, confirmed_count bigint, in_progress_count bigint, completed_count bigint, cancelled_count bigint, total_count bigint)
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
  SELECT 
    COUNT(*) FILTER (WHERE 
      booking_status NOT IN ('completed', 'cancelled', 'declined', 'no_show') 
      AND booking_date <= CURRENT_DATE
    ) AS present_count,
    
    COUNT(*) FILTER (WHERE 
      booking_status NOT IN ('completed', 'cancelled', 'declined', 'no_show') 
      AND booking_date > CURRENT_DATE
    ) AS future_count,
    
    COUNT(*) FILTER (WHERE 
      booking_status IN ('completed', 'cancelled', 'declined', 'no_show')
    ) AS past_count,
    
    COUNT(*) FILTER (WHERE booking_status = 'pending') AS pending_count,
    COUNT(*) FILTER (WHERE booking_status = 'confirmed') AS confirmed_count,
    COUNT(*) FILTER (WHERE booking_status = 'in_progress') AS in_progress_count,
    COUNT(*) FILTER (WHERE booking_status = 'completed') AS completed_count,
    COUNT(*) FILTER (WHERE booking_status = 'cancelled') AS cancelled_count,
    COUNT(*) AS total_count
    
  FROM bookings
  WHERE business_id = p_business_id
    AND (p_provider_id IS NULL OR provider_id = p_provider_id)
    AND (p_date_from IS NULL OR booking_date >= p_date_from)
    AND (p_date_to IS NULL OR booking_date <= p_date_to);
$function$
;

CREATE OR REPLACE FUNCTION public.get_provider_bookings_paginated(p_business_id uuid, p_provider_id uuid DEFAULT NULL::uuid, p_status text DEFAULT NULL::text, p_category text DEFAULT NULL::text, p_date_from date DEFAULT NULL::date, p_date_to date DEFAULT NULL::date, p_search text DEFAULT NULL::text, p_limit integer DEFAULT 25, p_offset integer DEFAULT 0)
 RETURNS TABLE(booking jsonb, total_count bigint, stats jsonb)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_total_count BIGINT;
  v_stats JSONB;
BEGIN
  -- First, calculate total count and stats for the filtered set
  WITH filtered AS (
    SELECT 
      b.*,
      CASE 
        WHEN b.booking_status IN ('completed', 'cancelled', 'declined', 'no_show') THEN 'past'
        WHEN b.booking_date > CURRENT_DATE THEN 'future'
        ELSE 'present'
      END AS category
    FROM bookings b
    LEFT JOIN customer_profiles cp ON b.customer_id = cp.id
    LEFT JOIN services s ON b.service_id = s.id
    WHERE b.business_id = p_business_id
      AND (p_provider_id IS NULL OR b.provider_id = p_provider_id)
      AND (p_status IS NULL OR b.booking_status = p_status)
      AND (p_date_from IS NULL OR b.booking_date >= p_date_from)
      AND (p_date_to IS NULL OR b.booking_date <= p_date_to)
      AND (p_search IS NULL OR p_search = '' OR (
        cp.first_name ILIKE '%' || p_search || '%' OR
        cp.last_name ILIKE '%' || p_search || '%' OR
        s.name ILIKE '%' || p_search || '%' OR
        b.booking_reference ILIKE '%' || p_search || '%'
      ))
  )
  SELECT 
    COUNT(*),
    jsonb_build_object(
      'total_bookings', COUNT(*),
      'pending_bookings', COUNT(*) FILTER (WHERE booking_status = 'pending'),
      'confirmed_bookings', COUNT(*) FILTER (WHERE booking_status = 'confirmed'),
      'completed_bookings', COUNT(*) FILTER (WHERE booking_status = 'completed'),
      'cancelled_bookings', COUNT(*) FILTER (WHERE booking_status = 'cancelled'),
      'in_progress_bookings', COUNT(*) FILTER (WHERE booking_status = 'in_progress'),
      'present_count', COUNT(*) FILTER (WHERE category = 'present'),
      'future_count', COUNT(*) FILTER (WHERE category = 'future'),
      'past_count', COUNT(*) FILTER (WHERE category = 'past'),
      'total_revenue', COALESCE(SUM(total_amount) FILTER (WHERE booking_status = 'completed'), 0),
      'pending_revenue', COALESCE(SUM(total_amount) FILTER (WHERE booking_status IN ('pending', 'confirmed')), 0)
    )
  INTO v_total_count, v_stats
  FROM filtered
  WHERE p_category IS NULL OR category = p_category;

  -- Return paginated results with stats
  RETURN QUERY
  SELECT 
    to_jsonb(pbe.*) AS booking,
    v_total_count AS total_count,
    v_stats AS stats
  FROM provider_bookings_enriched pbe
  WHERE pbe.business_id = p_business_id
    AND (p_provider_id IS NULL OR pbe.provider_id = p_provider_id)
    AND (p_status IS NULL OR pbe.booking_status = p_status)
    AND (p_category IS NULL OR pbe.booking_category = p_category)
    AND (p_date_from IS NULL OR pbe.booking_date >= p_date_from)
    AND (p_date_to IS NULL OR pbe.booking_date <= p_date_to)
    AND (p_search IS NULL OR p_search = '' OR (
      pbe.customer_first_name ILIKE '%' || p_search || '%' OR
      pbe.customer_last_name ILIKE '%' || p_search || '%' OR
      pbe.service_name ILIKE '%' || p_search || '%' OR
      pbe.booking_reference ILIKE '%' || p_search || '%'
    ))
  ORDER BY pbe.booking_date DESC, pbe.start_time DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_provider_conversations(p_user_id uuid, p_user_type text, p_business_id uuid DEFAULT NULL::uuid, p_provider_id uuid DEFAULT NULL::uuid, p_unread_only boolean DEFAULT false, p_limit integer DEFAULT 50, p_offset integer DEFAULT 0)
 RETURNS TABLE(conversation jsonb, unread_count bigint, total_count bigint)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_total_count BIGINT;
  v_provider_types TEXT[] := ARRAY['provider', 'owner', 'dispatcher'];
BEGIN
  -- First get total count
  SELECT COUNT(DISTINCT pce.metadata_id)
  INTO v_total_count
  FROM provider_conversations_enriched pce
  JOIN conversation_participants cp ON cp.conversation_id = pce.metadata_id
  LEFT JOIN (
    SELECT conversation_id, COUNT(*) as cnt
    FROM message_notifications
    WHERE user_id = p_user_id AND is_read = false
    GROUP BY conversation_id
  ) mn ON mn.conversation_id = pce.metadata_id
  WHERE cp.user_id = p_user_id
    AND cp.is_active = true
    AND (
      -- Provider-side users match any provider role type
      (p_user_type = ANY(v_provider_types) AND cp.user_type = ANY(v_provider_types))
      OR 
      -- Customers match exactly
      (p_user_type = 'customer' AND cp.user_type = 'customer')
    )
    AND (p_business_id IS NULL OR pce.business_id = p_business_id)
    AND (p_provider_id IS NULL OR pce.provider_id = p_provider_id)
    AND (NOT p_unread_only OR COALESCE(mn.cnt, 0) > 0);

  -- Return paginated results with unread counts
  RETURN QUERY
  SELECT 
    jsonb_build_object(
      'metadataId', pce.metadata_id,
      'bookingId', pce.booking_id,
      'twilioConversationSid', pce.twilio_conversation_sid,
      'conversationType', pce.conversation_type,
      'participantCount', pce.participant_count,
      'isActive', pce.is_active,
      'createdAt', pce.created_at,
      'updatedAt', pce.updated_at,
      'lastMessageAt', pce.last_message_at,
      'lastMessage', CASE 
        WHEN pce.last_message_body IS NOT NULL THEN
          jsonb_build_object(
            'body', pce.last_message_body,
            'author', pce.last_message_author,
            'authorName', pce.last_message_author_name,
            'timestamp', pce.last_message_timestamp
          )
        ELSE NULL
      END,
      'booking', jsonb_build_object(
        'id', pce.booking_id_ref,
        'booking_date', pce.booking_date,
        'booking_status', pce.booking_status,
        'service_name', pce.service_name,
        'business_id', pce.business_id,
        'customer_profiles', CASE 
          WHEN pce.customer_id IS NOT NULL THEN
            jsonb_build_object(
              'id', pce.customer_id,
              'user_id', pce.customer_user_id,
              'first_name', pce.customer_first_name,
              'last_name', pce.customer_last_name,
              'email', pce.customer_email,
              'image_url', pce.customer_image_url
            )
          ELSE NULL
        END,
        'providers', CASE 
          WHEN pce.provider_id_ref IS NOT NULL THEN
            jsonb_build_object(
              'id', pce.provider_id_ref,
              'user_id', pce.provider_user_id,
              'first_name', pce.provider_first_name,
              'last_name', pce.provider_last_name,
              'email', pce.provider_email,
              'provider_role', pce.provider_role,
              'image_url', pce.provider_image_url
            )
          ELSE NULL
        END
      )
    ) AS conversation,
    COALESCE(mn.cnt, 0)::BIGINT AS unread_count,
    v_total_count AS total_count
  FROM provider_conversations_enriched pce
  JOIN conversation_participants cp ON cp.conversation_id = pce.metadata_id
  LEFT JOIN (
    SELECT conversation_id, COUNT(*) as cnt
    FROM message_notifications
    WHERE user_id = p_user_id AND is_read = false
    GROUP BY conversation_id
  ) mn ON mn.conversation_id = pce.metadata_id
  WHERE cp.user_id = p_user_id
    AND cp.is_active = true
    AND (
      (p_user_type = ANY(v_provider_types) AND cp.user_type = ANY(v_provider_types))
      OR 
      (p_user_type = 'customer' AND cp.user_type = 'customer')
    )
    AND (p_business_id IS NULL OR pce.business_id = p_business_id)
    AND (p_provider_id IS NULL OR pce.provider_id = p_provider_id)
    AND (NOT p_unread_only OR COALESCE(mn.cnt, 0) > 0)
  ORDER BY pce.last_message_at DESC NULLS LAST, pce.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_provider_dashboard_stats(p_business_id uuid)
 RETURNS TABLE(total_bookings bigint, pending_bookings bigint, confirmed_bookings bigint, completed_bookings bigint, cancelled_bookings bigint, in_progress_bookings bigint, bookings_today bigint, bookings_scheduled_today bigint, bookings_this_week bigint, total_revenue numeric, pending_revenue numeric, revenue_today numeric, revenue_this_week numeric, revenue_this_month numeric, average_booking_value numeric, total_staff bigint, active_staff bigint, total_services bigint, active_services bigint, unique_customers bigint, repeat_customers bigint, total_locations bigint, active_locations bigint, completion_rate_percent numeric, cancellation_rate_percent numeric, bookings_last_30_days bigint, revenue_last_30_days numeric, new_customers_last_30_days bigint, bookings_growth_percent numeric, revenue_growth_percent numeric, stats_generated_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_bookings_prev_30 BIGINT;
  v_revenue_prev_30 NUMERIC;
BEGIN
  -- Calculate previous 30 days for growth metrics
  SELECT COUNT(*), COALESCE(SUM(total_amount), 0)
  INTO v_bookings_prev_30, v_revenue_prev_30
  FROM bookings
  WHERE business_id = p_business_id
    AND created_at >= CURRENT_DATE - INTERVAL '60 days'
    AND created_at < CURRENT_DATE - INTERVAL '30 days';

  RETURN QUERY
  SELECT
    -- Booking Statistics
    (SELECT COUNT(*) FROM bookings WHERE business_id = p_business_id)::BIGINT,
    (SELECT COUNT(*) FROM bookings WHERE business_id = p_business_id AND booking_status = 'pending')::BIGINT,
    (SELECT COUNT(*) FROM bookings WHERE business_id = p_business_id AND booking_status = 'confirmed')::BIGINT,
    (SELECT COUNT(*) FROM bookings WHERE business_id = p_business_id AND booking_status = 'completed')::BIGINT,
    (SELECT COUNT(*) FROM bookings WHERE business_id = p_business_id AND booking_status = 'cancelled')::BIGINT,
    (SELECT COUNT(*) FROM bookings WHERE business_id = p_business_id AND booking_status = 'in_progress')::BIGINT,
    
    -- Today's Bookings
    (SELECT COUNT(*) FROM bookings WHERE business_id = p_business_id AND DATE(created_at) = CURRENT_DATE)::BIGINT,
    (SELECT COUNT(*) FROM bookings WHERE business_id = p_business_id AND DATE(booking_date) = CURRENT_DATE)::BIGINT,
    
    -- This Week
    (SELECT COUNT(*) FROM bookings WHERE business_id = p_business_id AND created_at >= DATE_TRUNC('week', CURRENT_DATE))::BIGINT,
    
    -- Revenue Statistics
    COALESCE((SELECT SUM(total_amount) FROM bookings WHERE business_id = p_business_id AND booking_status = 'completed'), 0)::NUMERIC,
    COALESCE((SELECT SUM(total_amount) FROM bookings WHERE business_id = p_business_id AND booking_status IN ('pending', 'confirmed', 'in_progress')), 0)::NUMERIC,
    COALESCE((SELECT SUM(total_amount) FROM bookings WHERE business_id = p_business_id AND booking_status = 'completed' AND DATE(created_at) = CURRENT_DATE), 0)::NUMERIC,
    COALESCE((SELECT SUM(total_amount) FROM bookings WHERE business_id = p_business_id AND booking_status = 'completed' AND created_at >= DATE_TRUNC('week', CURRENT_DATE)), 0)::NUMERIC,
    COALESCE((SELECT SUM(total_amount) FROM bookings WHERE business_id = p_business_id AND booking_status = 'completed' AND created_at >= DATE_TRUNC('month', CURRENT_DATE)), 0)::NUMERIC,
    
    -- Average Booking Value
    COALESCE((
      SELECT ROUND(AVG(total_amount)::NUMERIC, 2) 
      FROM bookings 
      WHERE business_id = p_business_id AND booking_status = 'completed' AND total_amount > 0
    ), 0)::NUMERIC,
    
    -- Staff Statistics
    (SELECT COUNT(*) FROM providers WHERE business_id = p_business_id)::BIGINT,
    (SELECT COUNT(*) FROM providers WHERE business_id = p_business_id AND is_active = true)::BIGINT,
    
    -- Service Statistics
    (SELECT COUNT(*) FROM business_services WHERE business_id = p_business_id)::BIGINT,
    (SELECT COUNT(*) FROM business_services WHERE business_id = p_business_id AND is_active = true)::BIGINT,
    
    -- Customer Statistics (unique customers who have booked with this business)
    (SELECT COUNT(DISTINCT customer_id) FROM bookings WHERE business_id = p_business_id)::BIGINT,
    (SELECT COUNT(*) FROM (
      SELECT customer_id 
      FROM bookings 
      WHERE business_id = p_business_id 
      GROUP BY customer_id 
      HAVING COUNT(*) > 1
    ) AS repeat)::BIGINT,
    
    -- Location Statistics
    (SELECT COUNT(*) FROM business_locations WHERE business_id = p_business_id)::BIGINT,
    (SELECT COUNT(*) FROM business_locations WHERE business_id = p_business_id AND is_active = true)::BIGINT,
    
    -- Performance Rates
    CASE 
      WHEN (SELECT COUNT(*) FROM bookings WHERE business_id = p_business_id) > 0 
      THEN ROUND(
        (SELECT COUNT(*) FROM bookings WHERE business_id = p_business_id AND booking_status = 'completed')::NUMERIC / 
        (SELECT COUNT(*) FROM bookings WHERE business_id = p_business_id)::NUMERIC * 100, 2
      )
      ELSE 0 
    END::NUMERIC,
    
    CASE 
      WHEN (SELECT COUNT(*) FROM bookings WHERE business_id = p_business_id) > 0 
      THEN ROUND(
        (SELECT COUNT(*) FROM bookings WHERE business_id = p_business_id AND booking_status = 'cancelled')::NUMERIC / 
        (SELECT COUNT(*) FROM bookings WHERE business_id = p_business_id)::NUMERIC * 100, 2
      )
      ELSE 0 
    END::NUMERIC,
    
    -- Recent Activity (Last 30 Days)
    (SELECT COUNT(*) FROM bookings WHERE business_id = p_business_id AND created_at >= CURRENT_DATE - INTERVAL '30 days')::BIGINT,
    COALESCE((SELECT SUM(total_amount) FROM bookings WHERE business_id = p_business_id AND booking_status = 'completed' AND created_at >= CURRENT_DATE - INTERVAL '30 days'), 0)::NUMERIC,
    (SELECT COUNT(DISTINCT customer_id) FROM bookings WHERE business_id = p_business_id AND created_at >= CURRENT_DATE - INTERVAL '30 days')::BIGINT,
    
    -- Growth Metrics
    CASE 
      WHEN v_bookings_prev_30 > 0
      THEN ROUND(
        ((SELECT COUNT(*) FROM bookings WHERE business_id = p_business_id AND created_at >= CURRENT_DATE - INTERVAL '30 days')::NUMERIC - v_bookings_prev_30::NUMERIC) / 
        v_bookings_prev_30::NUMERIC * 100, 2
      )
      ELSE 0 
    END::NUMERIC,
    
    CASE 
      WHEN v_revenue_prev_30 > 0
      THEN ROUND(
        (COALESCE((SELECT SUM(total_amount) FROM bookings WHERE business_id = p_business_id AND booking_status = 'completed' AND created_at >= CURRENT_DATE - INTERVAL '30 days'), 0) - v_revenue_prev_30) / 
        v_revenue_prev_30 * 100, 2
      )
      ELSE 0 
    END::NUMERIC,
    
    -- Timestamp
    CURRENT_TIMESTAMP;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_user_mfa_status(check_user_id uuid)
 RETURNS TABLE(mfa_enabled boolean, mfa_required boolean, primary_factor_id uuid, primary_method mfa_method_type, backup_codes_enabled boolean, backup_codes_count integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN QUERY
    SELECT 
        ms.mfa_enabled,
        ms.mfa_required,
        mf.id as primary_factor_id,
        mf.method as primary_method,
        ms.backup_codes_enabled,
        ms.backup_codes_count
    FROM public.mfa_settings ms
    LEFT JOIN public.mfa_factors mf ON ms.user_id = mf.user_id AND mf.is_primary = true
    WHERE ms.user_id = check_user_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_user_roles(check_user_id uuid)
 RETURNS TABLE(role user_role_type, business_id uuid, business_name text)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN QUERY
    SELECT 
        ur.role,
        ur.business_id,
        bp.business_name
    FROM user_roles ur
    LEFT JOIN business_profiles bp ON ur.business_id = bp.id
    WHERE ur.user_id = check_user_id 
    AND ur.is_active = true
    AND (ur.expires_at IS NULL OR ur.expires_at > NOW());
END;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  new.updated_at = now();
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.has_mfa_completed_for_session(check_user_id uuid, check_session_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.mfa_sessions ms
        WHERE ms.user_id = check_user_id 
        AND ms.session_id = check_session_id
        AND ms.expires_at > NOW()
    );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.has_role(user_id uuid, role_name text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  return exists (
    select 1 from public.user_roles
    where user_roles.user_id = has_role.user_id
    and user_roles.role = role_name
  );
end;
$function$
;

CREATE OR REPLACE FUNCTION public.is_business_favorited(business_id_param uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
DECLARE
    customer_id_var UUID;
    is_favorited BOOLEAN;
BEGIN
    -- Get the customer_id for the current user
    SELECT id INTO customer_id_var 
    FROM public.customer_profiles 
    WHERE user_id = auth.uid();
    
    IF customer_id_var IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Check if the business is favorited
    SELECT EXISTS (
        SELECT 1 
        FROM public.customer_favorite_businesses 
        WHERE customer_id = customer_id_var AND business_id = business_id_param
    ) INTO is_favorited;
    
    RETURN is_favorited;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_provider_favorited(provider_id_param uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
DECLARE
    customer_id_var UUID;
    is_favorited BOOLEAN;
BEGIN
    -- Get the customer_id for the current user
    SELECT id INTO customer_id_var 
    FROM public.customer_profiles 
    WHERE user_id = auth.uid();
    
    IF customer_id_var IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Check if the provider is favorited
    SELECT EXISTS (
        SELECT 1 
        FROM public.customer_favorite_providers 
        WHERE customer_id = customer_id_var AND provider_id = provider_id_param
    ) INTO is_favorited;
    
    RETURN is_favorited;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_service_favorited(service_id_param uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
DECLARE
    customer_id_var UUID;
    is_favorited BOOLEAN;
BEGIN
    -- Get the customer_id for the current user
    SELECT id INTO customer_id_var 
    FROM public.customer_profiles 
    WHERE user_id = auth.uid();
    
    IF customer_id_var IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Check if the service is favorited
    SELECT EXISTS (
        SELECT 1 
        FROM public.customer_favorite_services 
        WHERE customer_id = customer_id_var AND service_id = service_id_param
    ) INTO is_favorited;
    
    RETURN is_favorited;
END;
$function$
;

create or replace view "public"."provider_bookings_enriched" as  SELECT b.id,
    b.booking_reference,
    b.business_id,
    b.provider_id,
    b.customer_id,
    b.service_id,
    b.booking_date,
    b.start_time,
    b.booking_status,
    b.payment_status,
    b.total_amount,
    b.service_fee,
    b.remaining_balance,
    b.tip_amount,
    b.cancellation_reason,
    b.cancelled_by,
    b.cancelled_at,
    b.admin_notes,
    b.special_instructions,
    b.delivery_type,
    b.guest_name,
    b.guest_email,
    b.guest_phone,
    b.created_at,
    cp.first_name AS customer_first_name,
    cp.last_name AS customer_last_name,
    cp.email AS customer_email,
    cp.phone AS customer_phone,
    cp.image_url AS customer_image_url,
    s.name AS service_name,
    s.description AS service_description,
    s.duration_minutes AS service_duration,
    s.min_price AS service_min_price,
    p.first_name AS provider_first_name,
    p.last_name AS provider_last_name,
    p.image_url AS provider_image_url,
    cl.location_name AS customer_location_name,
    cl.street_address AS customer_street_address,
    cl.city AS customer_city,
    cl.state AS customer_state,
    cl.zip_code AS customer_zip_code,
    bl.location_name AS business_location_name,
    bl.address_line1 AS business_address,
    bl.city AS business_city,
    bl.state AS business_state,
    bl.postal_code AS business_postal_code,
        CASE
            WHEN (b.booking_status = ANY (ARRAY['completed'::booking_status, 'cancelled'::booking_status, 'declined'::booking_status, 'no_show'::booking_status])) THEN 'past'::text
            WHEN (b.booking_date > CURRENT_DATE) THEN 'future'::text
            ELSE 'present'::text
        END AS booking_category,
    bpt.gross_payment_amount,
    bpt.net_payment_amount,
    bpt.payment_date AS last_payment_date
   FROM ((((((bookings b
     LEFT JOIN customer_profiles cp ON ((b.customer_id = cp.id)))
     LEFT JOIN services s ON ((b.service_id = s.id)))
     LEFT JOIN providers p ON ((b.provider_id = p.id)))
     LEFT JOIN customer_locations cl ON ((b.customer_location_id = cl.id)))
     LEFT JOIN business_locations bl ON ((b.business_location_id = bl.id)))
     LEFT JOIN LATERAL ( SELECT business_payment_transactions.gross_payment_amount,
            business_payment_transactions.net_payment_amount,
            business_payment_transactions.payment_date
           FROM business_payment_transactions
          WHERE (business_payment_transactions.booking_id = b.id)
          ORDER BY business_payment_transactions.created_at DESC
         LIMIT 1) bpt ON (true));


create or replace view "public"."provider_conversations_enriched" as  SELECT cm.id AS metadata_id,
    cm.booking_id,
    cm.twilio_conversation_sid,
    cm.conversation_type,
    cm.participant_count,
    cm.is_active,
    cm.created_at,
    cm.updated_at,
    cm.last_message_at,
    cm.last_message_body,
    cm.last_message_author,
    cm.last_message_author_name,
    cm.last_message_timestamp,
    b.id AS booking_id_ref,
    b.booking_date,
    b.booking_status,
    b.business_id,
    b.provider_id,
    s.name AS service_name,
    cp.id AS customer_id,
    cp.user_id AS customer_user_id,
    cp.first_name AS customer_first_name,
    cp.last_name AS customer_last_name,
    cp.email AS customer_email,
    cp.image_url AS customer_image_url,
    p.id AS provider_id_ref,
    p.user_id AS provider_user_id,
    p.first_name AS provider_first_name,
    p.last_name AS provider_last_name,
    p.email AS provider_email,
    p.provider_role,
    p.image_url AS provider_image_url
   FROM ((((conversation_metadata cm
     LEFT JOIN bookings b ON ((cm.booking_id = b.id)))
     LEFT JOIN services s ON ((b.service_id = s.id)))
     LEFT JOIN customer_profiles cp ON ((b.customer_id = cp.id)))
     LEFT JOIN providers p ON ((b.provider_id = p.id)))
  WHERE (cm.is_active = true);


CREATE OR REPLACE FUNCTION public.purge_old_conversation_data()
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Delete conversation_participants older than 90 days
  DELETE FROM public.conversation_participants
  WHERE conversation_id IN (
    SELECT id FROM public.conversation_metadata
    WHERE created_at < (CURRENT_DATE - INTERVAL '90 days')
  );
  
  -- Delete message_notifications older than 90 days
  DELETE FROM public.message_notifications
  WHERE conversation_id IN (
    SELECT id FROM public.conversation_metadata
    WHERE created_at < (CURRENT_DATE - INTERVAL '90 days')
  );
  
  -- Delete message_analytics older than 90 days
  DELETE FROM public.message_analytics
  WHERE conversation_id IN (
    SELECT id FROM public.conversation_metadata
    WHERE created_at < (CURRENT_DATE - INTERVAL '90 days')
  );
  
  -- Finally, delete the conversation_metadata records
  DELETE FROM public.conversation_metadata
  WHERE created_at < (CURRENT_DATE - INTERVAL '90 days');
END;
$function$
;

CREATE OR REPLACE FUNCTION public.remove_business_from_favorites(business_id_param uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
DECLARE
    customer_id_var UUID;
    rows_deleted INTEGER;
BEGIN
    -- Get the customer_id for the current user
    SELECT id INTO customer_id_var 
    FROM public.customer_profiles 
    WHERE user_id = auth.uid();
    
    IF customer_id_var IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Remove from favorites
    DELETE FROM public.customer_favorite_businesses 
    WHERE customer_id = customer_id_var AND business_id = business_id_param
    RETURNING 1 INTO rows_deleted;
    
    RETURN rows_deleted > 0;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.remove_favorite_business(business_id_param uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
    customer_id_var UUID;
    rows_deleted INTEGER;
BEGIN
    -- Get the customer_id for the current user
    SELECT id INTO customer_id_var 
    FROM public.customer_profiles 
    WHERE user_id = auth.uid();
    
    IF customer_id_var IS NULL THEN
        RAISE EXCEPTION 'Customer profile not found';
    END IF;
    
    -- Delete the favorite business
    DELETE FROM public.customer_favorite_businesses
    WHERE customer_id = customer_id_var AND business_id = business_id_param;
    
    GET DIAGNOSTICS rows_deleted = ROW_COUNT;
    
    RETURN rows_deleted > 0;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.remove_favorite_provider(provider_id_param uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
    customer_id_var UUID;
    rows_deleted INTEGER;
BEGIN
    -- Get the customer_id for the current user
    SELECT id INTO customer_id_var 
    FROM public.customer_profiles 
    WHERE user_id = auth.uid();
    
    IF customer_id_var IS NULL THEN
        RAISE EXCEPTION 'Customer profile not found';
    END IF;
    
    -- Delete the favorite provider
    DELETE FROM public.customer_favorite_providers
    WHERE customer_id = customer_id_var AND provider_id = provider_id_param;
    
    GET DIAGNOSTICS rows_deleted = ROW_COUNT;
    
    RETURN rows_deleted > 0;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.remove_favorite_service(service_id_param uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
    customer_id_var UUID;
    rows_deleted INTEGER;
BEGIN
    -- Get the customer_id for the current user
    SELECT id INTO customer_id_var 
    FROM public.customer_profiles 
    WHERE user_id = auth.uid();
    
    IF customer_id_var IS NULL THEN
        RAISE EXCEPTION 'Customer profile not found';
    END IF;
    
    -- Delete the favorite service
    DELETE FROM public.customer_favorite_services
    WHERE customer_id = customer_id_var AND service_id = service_id_param;
    
    GET DIAGNOSTICS rows_deleted = ROW_COUNT;
    
    RETURN rows_deleted > 0;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.remove_provider_from_favorites(provider_id_param uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
DECLARE
    customer_id_var UUID;
    rows_deleted INTEGER;
BEGIN
    -- Get the customer_id for the current user
    SELECT id INTO customer_id_var 
    FROM public.customer_profiles 
    WHERE user_id = auth.uid();
    
    IF customer_id_var IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Remove from favorites
    DELETE FROM public.customer_favorite_providers 
    WHERE customer_id = customer_id_var AND provider_id = provider_id_param
    RETURNING 1 INTO rows_deleted;
    
    RETURN rows_deleted > 0;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.remove_service_from_favorites(service_id_param uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
DECLARE
    customer_id_var UUID;
    rows_deleted INTEGER;
BEGIN
    -- Get the customer_id for the current user
    SELECT id INTO customer_id_var 
    FROM public.customer_profiles 
    WHERE user_id = auth.uid();
    
    IF customer_id_var IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Remove from favorites
    DELETE FROM public.customer_favorite_services 
    WHERE customer_id = customer_id_var AND service_id = service_id_param
    RETURNING 1 INTO rows_deleted;
    
    RETURN rows_deleted > 0;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.send_business_approval_email()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
    business_name TEXT;
    contact_name TEXT;
    email_subject TEXT;
    email_content TEXT;
BEGIN
    -- Only proceed if status changed to 'approved'
    IF NEW.verification_status = 'approved' AND 
       (OLD.verification_status IS NULL OR OLD.verification_status != 'approved') THEN
        
        -- Get business name and contact name
        business_name := COALESCE(NEW.business_name, 'your business');
        contact_name := COALESCE(NEW.contact_name, 'there');
        
        -- Set email subject
        email_subject := 'Welcome to ROAM - Your Business is Approved!';
        
        -- Create email content with HTML formatting
        email_content := '
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    line-height: 1.6;
                    color: #333;
                }
                .container {
                    max-width: 600px;
                    margin: 0 auto;
                    padding: 20px;
                }
                .header {
                    background-color: #4A90E2;
                    color: white;
                    padding: 20px;
                    text-align: center;
                }
                .content {
                    padding: 20px;
                }
                .button {
                    display: inline-block;
                    background-color: #4A90E2;
                    color: white;
                    padding: 12px 24px;
                    text-decoration: none;
                    border-radius: 4px;
                    margin: 20px 0;
                }
                .footer {
                    font-size: 12px;
                    color: #777;
                    text-align: center;
                    margin-top: 30px;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>Welcome to ROAM!</h1>
                </div>
                <div class="content">
                    <p>Hello ' || contact_name || ',</p>
                    
                    <p>Congratulations! <strong>' || business_name || '</strong> has been approved on ROAM.</p>
                    
                    <p>We''re excited to have you join our community of businesses helping people roam their best life. Your business profile is now visible to potential customers on our platform.</p>
                    
                    <p>To complete your onboarding and start managing your business profile:</p>
                    
                    <p style="text-align: center;">
                        <a href="https://roamyourbestlife.com" class="button">Login to Your ROAM Dashboard</a>
                    </p>
                    
                    <p>In your dashboard, you can:</p>
                    <ul>
                        <li>Complete your business profile</li>
                        <li>Add services and providers</li>
                        <li>Set up your availability</li>
                        <li>Manage bookings</li>
                    </ul>
                    
                    <p>If you have any questions or need assistance, please don''t hesitate to contact our support team.</p>
                    
                    <p>Best regards,<br>The ROAM Team</p>
                </div>
                <div class="footer">
                    <p>© 2023 ROAM. All rights reserved.</p>
                    <p>This email was sent to you because you registered a business on ROAM.</p>
                </div>
            </div>
        </body>
        </html>
        ';
        
        -- Send email using Supabase's net.http_post function to call the Email API
        PERFORM net.http_post(
            url:='https://api.supabase.com/v1/projects/' || current_setting('request.project_id', true) || '/email',
            headers:=jsonb_build_object(
                'Content-Type', 'application/json',
                'Authorization', 'Bearer ' || current_setting('request.service_role_key', true)
            ),
            body:=jsonb_build_object(
                'to', NEW.contact_email,
                'subject', email_subject,
                'html', email_content
            )
        );
        
        -- Log the email sending
        INSERT INTO public.email_logs (
            recipient_email,
            email_type,
            subject,
            sent_at,
            business_id
        ) VALUES (
            NEW.contact_email,
            'business_approval',
            email_subject,
            NOW(),
            NEW.id
        );
    END IF;
    
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.set_bsti_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.track_business_payment_for_tax()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  current_year INTEGER;
  business_new_total NUMERIC(12,2);
  platform_fee NUMERIC(10,2);
  net_payment NUMERIC(10,2);
BEGIN
  -- Only process when payment status changes to 'paid'
  IF NEW.payment_status = 'paid' AND (OLD.payment_status IS NULL OR OLD.payment_status != 'paid') THEN
    
    -- Get current tax year
    current_year := EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;
    
    -- Calculate platform fee and net payment to business
    platform_fee := COALESCE(NEW.service_fee, 0);
    net_payment := NEW.total_amount - platform_fee;
    
    -- Get business_id from provider (assuming providers table has business_id)
    -- Create payment transaction record
    INSERT INTO public.business_payment_transactions (
      booking_id,
      business_id,
      payment_date,
      gross_payment_amount,
      platform_fee,
      net_payment_amount,
      tax_year,
      stripe_payment_intent_id,
      booking_reference,
      transaction_description
    )
    SELECT 
      NEW.id,
      p.business_id,
      CURRENT_DATE,
      NEW.total_amount,
      platform_fee,
      net_payment,
      current_year,
      NEW.id::TEXT, -- Use booking ID as payment reference
      NEW.booking_reference,
      'Platform service payment for booking #' || COALESCE(NEW.booking_reference, NEW.id::TEXT)
    FROM public.providers p
    WHERE p.id = NEW.provider_id
    ON CONFLICT (booking_id) DO NOTHING; -- Prevent duplicates
    
    -- Update business annual tax tracking
    INSERT INTO public.business_annual_tax_tracking (
      business_id,
      tax_year,
      total_payments_received,
      payment_count,
      first_payment_date,
      last_payment_date
    )
    SELECT 
      p.business_id,
      current_year,
      net_payment,
      1,
      CURRENT_DATE,
      CURRENT_DATE
    FROM public.providers p
    WHERE p.id = NEW.provider_id
    ON CONFLICT (business_id, tax_year) 
    DO UPDATE SET 
      total_payments_received = business_annual_tax_tracking.total_payments_received + net_payment,
      payment_count = business_annual_tax_tracking.payment_count + 1,
      last_payment_date = CURRENT_DATE,
      updated_at = NOW();
    
    -- Get updated business total for this tax year
    SELECT batt.total_payments_received INTO business_new_total
    FROM public.business_annual_tax_tracking batt
    JOIN public.providers p ON p.business_id = batt.business_id
    WHERE p.id = NEW.provider_id 
      AND batt.tax_year = current_year;
    
    -- Update 1099 eligibility if $600 threshold reached
    IF business_new_total >= 600 THEN
      UPDATE public.business_annual_tax_tracking 
      SET 
        requires_1099 = TRUE,
        threshold_reached_date = CASE 
          WHEN threshold_reached_date IS NULL THEN CURRENT_DATE 
          ELSE threshold_reached_date 
        END
      FROM public.providers p
      WHERE business_annual_tax_tracking.business_id = p.business_id
        AND p.id = NEW.provider_id
        AND business_annual_tax_tracking.tax_year = current_year;
    END IF;
    
    -- Update platform-wide summary
    INSERT INTO public.platform_annual_tax_summary (
      tax_year,
      total_businesses_paid,
      total_payments_made
    )
    VALUES (
      current_year,
      1,
      net_payment
    )
    ON CONFLICT (tax_year) 
    DO UPDATE SET 
      total_payments_made = platform_annual_tax_summary.total_payments_made + net_payment,
      updated_at = NOW();
    
    -- Update platform summary with 1099-eligible counts
    UPDATE public.platform_annual_tax_summary 
    SET 
      total_businesses_paid = (
        SELECT COUNT(DISTINCT business_id)
        FROM public.business_annual_tax_tracking
        WHERE tax_year = current_year
      ),
      businesses_requiring_1099 = (
        SELECT COUNT(*)
        FROM public.business_annual_tax_tracking
        WHERE tax_year = current_year
          AND requires_1099 = TRUE
      ),
      total_1099_eligible_payments = (
        SELECT COALESCE(SUM(total_payments_received), 0)
        FROM public.business_annual_tax_tracking
        WHERE tax_year = current_year
          AND requires_1099 = TRUE
      )
    WHERE tax_year = current_year;
    
  END IF;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_business_identity_verification()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- When verification status changes to 'verified', update business_profiles
  IF NEW.status = 'verified' AND (OLD.status IS NULL OR OLD.status != 'verified') THEN
    UPDATE business_profiles
    SET 
      identity_verification_session_id = NEW.session_id,
      identity_verification_status = 'verified',
      identity_verified_at = NOW(),
      identity_verification_data = NEW.verified_data
    WHERE id = NEW.business_id;
  END IF;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_business_service_categories_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_business_service_subcategories_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_conversation_last_message(p_conversation_id uuid, p_message_body text, p_author text, p_author_name text DEFAULT NULL::text, p_timestamp timestamp with time zone DEFAULT now())
 RETURNS void
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
  UPDATE conversation_metadata
  SET 
    last_message_body = p_message_body,
    last_message_author = p_author,
    last_message_author_name = p_author_name,
    last_message_timestamp = p_timestamp,
    last_message_at = p_timestamp
  WHERE id = p_conversation_id;
$function$
;

CREATE OR REPLACE FUNCTION public.update_manual_bank_accounts_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_mfa_factors_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_mfa_settings_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_plaid_bank_connections_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_provider_bank_accounts_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_provider_stats()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  avg_rating NUMERIC;
  total_reviews INTEGER;
BEGIN
  -- Calculate new average rating and total reviews for the provider
  SELECT 
    COALESCE(AVG(overall_rating), 0),
    COUNT(*)
  INTO 
    avg_rating,
    total_reviews
  FROM 
    reviews
  WHERE 
    provider_id = NEW.provider_id
    AND is_approved = true;
  
  -- Update the provider record
  UPDATE providers
  SET 
    average_rating = avg_rating,
    total_reviews = total_reviews
  WHERE 
    id = NEW.provider_id;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_provider_verifications_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
    new.updated_at = now();
    return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.update_user_roles_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.user_has_role(check_user_id uuid, check_role user_role_type, check_business_id uuid DEFAULT NULL::uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM user_roles 
        WHERE user_id = check_user_id 
        AND role = check_role
        AND is_active = true
        AND (check_business_id IS NULL OR business_id = check_business_id)
        AND (expires_at IS NULL OR expires_at > NOW())
    );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.validate_booking_location()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Check delivery_type and corresponding location fields
  CASE NEW.delivery_type
    WHEN 'customer_location' THEN
      IF NEW.customer_location_id IS NULL THEN
        RAISE EXCEPTION 'customer_location_id is required when delivery_type is customer_location';
      END IF;
    
    WHEN 'business_location' THEN
      IF NEW.business_location_id IS NULL THEN
        RAISE EXCEPTION 'business_location_id is required when delivery_type is business_location';
      END IF;
    
    WHEN 'virtual' THEN
      -- For virtual, neither location is required, but we don't need to check anything
      NULL;
      
    ELSE
      -- Handle unexpected delivery_type values
      RAISE EXCEPTION 'Invalid delivery_type: %', NEW.delivery_type;
  END CASE;
  
  -- Ensure that irrelevant location fields are NULL
  IF NEW.delivery_type = 'customer_location' AND NEW.business_location_id IS NOT NULL THEN
    RAISE EXCEPTION 'business_location_id should be NULL when delivery_type is customer_location';
  END IF;
  
  IF NEW.delivery_type = 'business_location' AND NEW.customer_location_id IS NOT NULL THEN
    RAISE EXCEPTION 'customer_location_id should be NULL when delivery_type is business_location';
  END IF;
  
  IF NEW.delivery_type = 'virtual' AND 
     (NEW.customer_location_id IS NOT NULL OR NEW.business_location_id IS NOT NULL) THEN
    RAISE EXCEPTION 'Both location fields should be NULL when delivery_type is virtual';
  END IF;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.validate_business_addon_eligibility()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Check if the addon is eligible for at least one service offered by this business
  IF NOT EXISTS (
    SELECT 1 
    FROM business_services bs
    JOIN service_addon_eligibility sae ON bs.service_id = sae.service_id
    WHERE bs.business_id = NEW.business_id 
    AND sae.addon_id = NEW.addon_id
    AND bs.is_active = TRUE
  ) THEN
    RAISE EXCEPTION 'Addon is not eligible for any services offered by this business';
  END IF;
  
  RETURN NEW;
END;
$function$
;

grant delete on table "public"."admin_users" to "anon";

grant insert on table "public"."admin_users" to "anon";

grant references on table "public"."admin_users" to "anon";

grant select on table "public"."admin_users" to "anon";

grant trigger on table "public"."admin_users" to "anon";

grant truncate on table "public"."admin_users" to "anon";

grant update on table "public"."admin_users" to "anon";

grant delete on table "public"."admin_users" to "authenticated";

grant insert on table "public"."admin_users" to "authenticated";

grant references on table "public"."admin_users" to "authenticated";

grant select on table "public"."admin_users" to "authenticated";

grant trigger on table "public"."admin_users" to "authenticated";

grant truncate on table "public"."admin_users" to "authenticated";

grant update on table "public"."admin_users" to "authenticated";

grant delete on table "public"."admin_users" to "service_role";

grant insert on table "public"."admin_users" to "service_role";

grant references on table "public"."admin_users" to "service_role";

grant select on table "public"."admin_users" to "service_role";

grant trigger on table "public"."admin_users" to "service_role";

grant truncate on table "public"."admin_users" to "service_role";

grant update on table "public"."admin_users" to "service_role";

grant delete on table "public"."announcements" to "anon";

grant insert on table "public"."announcements" to "anon";

grant references on table "public"."announcements" to "anon";

grant select on table "public"."announcements" to "anon";

grant trigger on table "public"."announcements" to "anon";

grant truncate on table "public"."announcements" to "anon";

grant update on table "public"."announcements" to "anon";

grant delete on table "public"."announcements" to "authenticated";

grant insert on table "public"."announcements" to "authenticated";

grant references on table "public"."announcements" to "authenticated";

grant select on table "public"."announcements" to "authenticated";

grant trigger on table "public"."announcements" to "authenticated";

grant truncate on table "public"."announcements" to "authenticated";

grant update on table "public"."announcements" to "authenticated";

grant delete on table "public"."announcements" to "service_role";

grant insert on table "public"."announcements" to "service_role";

grant references on table "public"."announcements" to "service_role";

grant select on table "public"."announcements" to "service_role";

grant trigger on table "public"."announcements" to "service_role";

grant truncate on table "public"."announcements" to "service_role";

grant update on table "public"."announcements" to "service_role";

grant delete on table "public"."booking_addons" to "anon";

grant insert on table "public"."booking_addons" to "anon";

grant references on table "public"."booking_addons" to "anon";

grant select on table "public"."booking_addons" to "anon";

grant trigger on table "public"."booking_addons" to "anon";

grant truncate on table "public"."booking_addons" to "anon";

grant update on table "public"."booking_addons" to "anon";

grant delete on table "public"."booking_addons" to "authenticated";

grant insert on table "public"."booking_addons" to "authenticated";

grant references on table "public"."booking_addons" to "authenticated";

grant select on table "public"."booking_addons" to "authenticated";

grant trigger on table "public"."booking_addons" to "authenticated";

grant truncate on table "public"."booking_addons" to "authenticated";

grant update on table "public"."booking_addons" to "authenticated";

grant delete on table "public"."booking_addons" to "service_role";

grant insert on table "public"."booking_addons" to "service_role";

grant references on table "public"."booking_addons" to "service_role";

grant select on table "public"."booking_addons" to "service_role";

grant trigger on table "public"."booking_addons" to "service_role";

grant truncate on table "public"."booking_addons" to "service_role";

grant update on table "public"."booking_addons" to "service_role";

grant delete on table "public"."booking_changes" to "anon";

grant insert on table "public"."booking_changes" to "anon";

grant references on table "public"."booking_changes" to "anon";

grant select on table "public"."booking_changes" to "anon";

grant trigger on table "public"."booking_changes" to "anon";

grant truncate on table "public"."booking_changes" to "anon";

grant update on table "public"."booking_changes" to "anon";

grant delete on table "public"."booking_changes" to "authenticated";

grant insert on table "public"."booking_changes" to "authenticated";

grant references on table "public"."booking_changes" to "authenticated";

grant select on table "public"."booking_changes" to "authenticated";

grant trigger on table "public"."booking_changes" to "authenticated";

grant truncate on table "public"."booking_changes" to "authenticated";

grant update on table "public"."booking_changes" to "authenticated";

grant delete on table "public"."booking_changes" to "service_role";

grant insert on table "public"."booking_changes" to "service_role";

grant references on table "public"."booking_changes" to "service_role";

grant select on table "public"."booking_changes" to "service_role";

grant trigger on table "public"."booking_changes" to "service_role";

grant truncate on table "public"."booking_changes" to "service_role";

grant update on table "public"."booking_changes" to "service_role";

grant delete on table "public"."bookings" to "anon";

grant insert on table "public"."bookings" to "anon";

grant references on table "public"."bookings" to "anon";

grant select on table "public"."bookings" to "anon";

grant trigger on table "public"."bookings" to "anon";

grant truncate on table "public"."bookings" to "anon";

grant update on table "public"."bookings" to "anon";

grant delete on table "public"."bookings" to "authenticated";

grant insert on table "public"."bookings" to "authenticated";

grant references on table "public"."bookings" to "authenticated";

grant select on table "public"."bookings" to "authenticated";

grant trigger on table "public"."bookings" to "authenticated";

grant truncate on table "public"."bookings" to "authenticated";

grant update on table "public"."bookings" to "authenticated";

grant delete on table "public"."bookings" to "service_role";

grant insert on table "public"."bookings" to "service_role";

grant references on table "public"."bookings" to "service_role";

grant select on table "public"."bookings" to "service_role";

grant trigger on table "public"."bookings" to "service_role";

grant truncate on table "public"."bookings" to "service_role";

grant update on table "public"."bookings" to "service_role";

grant delete on table "public"."business_addons" to "anon";

grant insert on table "public"."business_addons" to "anon";

grant references on table "public"."business_addons" to "anon";

grant select on table "public"."business_addons" to "anon";

grant trigger on table "public"."business_addons" to "anon";

grant truncate on table "public"."business_addons" to "anon";

grant update on table "public"."business_addons" to "anon";

grant delete on table "public"."business_addons" to "authenticated";

grant insert on table "public"."business_addons" to "authenticated";

grant references on table "public"."business_addons" to "authenticated";

grant select on table "public"."business_addons" to "authenticated";

grant trigger on table "public"."business_addons" to "authenticated";

grant truncate on table "public"."business_addons" to "authenticated";

grant update on table "public"."business_addons" to "authenticated";

grant delete on table "public"."business_addons" to "service_role";

grant insert on table "public"."business_addons" to "service_role";

grant references on table "public"."business_addons" to "service_role";

grant select on table "public"."business_addons" to "service_role";

grant trigger on table "public"."business_addons" to "service_role";

grant truncate on table "public"."business_addons" to "service_role";

grant update on table "public"."business_addons" to "service_role";

grant delete on table "public"."business_annual_tax_tracking" to "anon";

grant insert on table "public"."business_annual_tax_tracking" to "anon";

grant references on table "public"."business_annual_tax_tracking" to "anon";

grant select on table "public"."business_annual_tax_tracking" to "anon";

grant trigger on table "public"."business_annual_tax_tracking" to "anon";

grant truncate on table "public"."business_annual_tax_tracking" to "anon";

grant update on table "public"."business_annual_tax_tracking" to "anon";

grant delete on table "public"."business_annual_tax_tracking" to "authenticated";

grant insert on table "public"."business_annual_tax_tracking" to "authenticated";

grant references on table "public"."business_annual_tax_tracking" to "authenticated";

grant select on table "public"."business_annual_tax_tracking" to "authenticated";

grant trigger on table "public"."business_annual_tax_tracking" to "authenticated";

grant truncate on table "public"."business_annual_tax_tracking" to "authenticated";

grant update on table "public"."business_annual_tax_tracking" to "authenticated";

grant delete on table "public"."business_annual_tax_tracking" to "service_role";

grant insert on table "public"."business_annual_tax_tracking" to "service_role";

grant references on table "public"."business_annual_tax_tracking" to "service_role";

grant select on table "public"."business_annual_tax_tracking" to "service_role";

grant trigger on table "public"."business_annual_tax_tracking" to "service_role";

grant truncate on table "public"."business_annual_tax_tracking" to "service_role";

grant update on table "public"."business_annual_tax_tracking" to "service_role";

grant delete on table "public"."business_documents" to "anon";

grant insert on table "public"."business_documents" to "anon";

grant references on table "public"."business_documents" to "anon";

grant select on table "public"."business_documents" to "anon";

grant trigger on table "public"."business_documents" to "anon";

grant truncate on table "public"."business_documents" to "anon";

grant update on table "public"."business_documents" to "anon";

grant delete on table "public"."business_documents" to "authenticated";

grant insert on table "public"."business_documents" to "authenticated";

grant references on table "public"."business_documents" to "authenticated";

grant select on table "public"."business_documents" to "authenticated";

grant trigger on table "public"."business_documents" to "authenticated";

grant truncate on table "public"."business_documents" to "authenticated";

grant update on table "public"."business_documents" to "authenticated";

grant delete on table "public"."business_documents" to "service_role";

grant insert on table "public"."business_documents" to "service_role";

grant references on table "public"."business_documents" to "service_role";

grant select on table "public"."business_documents" to "service_role";

grant trigger on table "public"."business_documents" to "service_role";

grant truncate on table "public"."business_documents" to "service_role";

grant update on table "public"."business_documents" to "service_role";

grant delete on table "public"."business_locations" to "anon";

grant insert on table "public"."business_locations" to "anon";

grant references on table "public"."business_locations" to "anon";

grant select on table "public"."business_locations" to "anon";

grant trigger on table "public"."business_locations" to "anon";

grant truncate on table "public"."business_locations" to "anon";

grant update on table "public"."business_locations" to "anon";

grant delete on table "public"."business_locations" to "authenticated";

grant insert on table "public"."business_locations" to "authenticated";

grant references on table "public"."business_locations" to "authenticated";

grant select on table "public"."business_locations" to "authenticated";

grant trigger on table "public"."business_locations" to "authenticated";

grant truncate on table "public"."business_locations" to "authenticated";

grant update on table "public"."business_locations" to "authenticated";

grant delete on table "public"."business_locations" to "service_role";

grant insert on table "public"."business_locations" to "service_role";

grant references on table "public"."business_locations" to "service_role";

grant select on table "public"."business_locations" to "service_role";

grant trigger on table "public"."business_locations" to "service_role";

grant truncate on table "public"."business_locations" to "service_role";

grant update on table "public"."business_locations" to "service_role";

grant delete on table "public"."business_manual_bank_accounts" to "anon";

grant insert on table "public"."business_manual_bank_accounts" to "anon";

grant references on table "public"."business_manual_bank_accounts" to "anon";

grant select on table "public"."business_manual_bank_accounts" to "anon";

grant trigger on table "public"."business_manual_bank_accounts" to "anon";

grant truncate on table "public"."business_manual_bank_accounts" to "anon";

grant update on table "public"."business_manual_bank_accounts" to "anon";

grant delete on table "public"."business_manual_bank_accounts" to "authenticated";

grant insert on table "public"."business_manual_bank_accounts" to "authenticated";

grant references on table "public"."business_manual_bank_accounts" to "authenticated";

grant select on table "public"."business_manual_bank_accounts" to "authenticated";

grant trigger on table "public"."business_manual_bank_accounts" to "authenticated";

grant truncate on table "public"."business_manual_bank_accounts" to "authenticated";

grant update on table "public"."business_manual_bank_accounts" to "authenticated";

grant delete on table "public"."business_manual_bank_accounts" to "service_role";

grant insert on table "public"."business_manual_bank_accounts" to "service_role";

grant references on table "public"."business_manual_bank_accounts" to "service_role";

grant select on table "public"."business_manual_bank_accounts" to "service_role";

grant trigger on table "public"."business_manual_bank_accounts" to "service_role";

grant truncate on table "public"."business_manual_bank_accounts" to "service_role";

grant update on table "public"."business_manual_bank_accounts" to "service_role";

grant delete on table "public"."business_payment_transactions" to "anon";

grant insert on table "public"."business_payment_transactions" to "anon";

grant references on table "public"."business_payment_transactions" to "anon";

grant select on table "public"."business_payment_transactions" to "anon";

grant trigger on table "public"."business_payment_transactions" to "anon";

grant truncate on table "public"."business_payment_transactions" to "anon";

grant update on table "public"."business_payment_transactions" to "anon";

grant delete on table "public"."business_payment_transactions" to "authenticated";

grant insert on table "public"."business_payment_transactions" to "authenticated";

grant references on table "public"."business_payment_transactions" to "authenticated";

grant select on table "public"."business_payment_transactions" to "authenticated";

grant trigger on table "public"."business_payment_transactions" to "authenticated";

grant truncate on table "public"."business_payment_transactions" to "authenticated";

grant update on table "public"."business_payment_transactions" to "authenticated";

grant delete on table "public"."business_payment_transactions" to "service_role";

grant insert on table "public"."business_payment_transactions" to "service_role";

grant references on table "public"."business_payment_transactions" to "service_role";

grant select on table "public"."business_payment_transactions" to "service_role";

grant trigger on table "public"."business_payment_transactions" to "service_role";

grant truncate on table "public"."business_payment_transactions" to "service_role";

grant update on table "public"."business_payment_transactions" to "service_role";

grant delete on table "public"."business_profiles" to "anon";

grant insert on table "public"."business_profiles" to "anon";

grant references on table "public"."business_profiles" to "anon";

grant select on table "public"."business_profiles" to "anon";

grant trigger on table "public"."business_profiles" to "anon";

grant truncate on table "public"."business_profiles" to "anon";

grant update on table "public"."business_profiles" to "anon";

grant delete on table "public"."business_profiles" to "authenticated";

grant insert on table "public"."business_profiles" to "authenticated";

grant references on table "public"."business_profiles" to "authenticated";

grant select on table "public"."business_profiles" to "authenticated";

grant trigger on table "public"."business_profiles" to "authenticated";

grant truncate on table "public"."business_profiles" to "authenticated";

grant update on table "public"."business_profiles" to "authenticated";

grant delete on table "public"."business_profiles" to "service_role";

grant insert on table "public"."business_profiles" to "service_role";

grant references on table "public"."business_profiles" to "service_role";

grant select on table "public"."business_profiles" to "service_role";

grant trigger on table "public"."business_profiles" to "service_role";

grant truncate on table "public"."business_profiles" to "service_role";

grant update on table "public"."business_profiles" to "service_role";

grant delete on table "public"."business_service_categories" to "anon";

grant insert on table "public"."business_service_categories" to "anon";

grant references on table "public"."business_service_categories" to "anon";

grant select on table "public"."business_service_categories" to "anon";

grant trigger on table "public"."business_service_categories" to "anon";

grant truncate on table "public"."business_service_categories" to "anon";

grant update on table "public"."business_service_categories" to "anon";

grant delete on table "public"."business_service_categories" to "authenticated";

grant insert on table "public"."business_service_categories" to "authenticated";

grant references on table "public"."business_service_categories" to "authenticated";

grant select on table "public"."business_service_categories" to "authenticated";

grant trigger on table "public"."business_service_categories" to "authenticated";

grant truncate on table "public"."business_service_categories" to "authenticated";

grant update on table "public"."business_service_categories" to "authenticated";

grant delete on table "public"."business_service_categories" to "service_role";

grant insert on table "public"."business_service_categories" to "service_role";

grant references on table "public"."business_service_categories" to "service_role";

grant select on table "public"."business_service_categories" to "service_role";

grant trigger on table "public"."business_service_categories" to "service_role";

grant truncate on table "public"."business_service_categories" to "service_role";

grant update on table "public"."business_service_categories" to "service_role";

grant delete on table "public"."business_service_subcategories" to "anon";

grant insert on table "public"."business_service_subcategories" to "anon";

grant references on table "public"."business_service_subcategories" to "anon";

grant select on table "public"."business_service_subcategories" to "anon";

grant trigger on table "public"."business_service_subcategories" to "anon";

grant truncate on table "public"."business_service_subcategories" to "anon";

grant update on table "public"."business_service_subcategories" to "anon";

grant delete on table "public"."business_service_subcategories" to "authenticated";

grant insert on table "public"."business_service_subcategories" to "authenticated";

grant references on table "public"."business_service_subcategories" to "authenticated";

grant select on table "public"."business_service_subcategories" to "authenticated";

grant trigger on table "public"."business_service_subcategories" to "authenticated";

grant truncate on table "public"."business_service_subcategories" to "authenticated";

grant update on table "public"."business_service_subcategories" to "authenticated";

grant delete on table "public"."business_service_subcategories" to "service_role";

grant insert on table "public"."business_service_subcategories" to "service_role";

grant references on table "public"."business_service_subcategories" to "service_role";

grant select on table "public"."business_service_subcategories" to "service_role";

grant trigger on table "public"."business_service_subcategories" to "service_role";

grant truncate on table "public"."business_service_subcategories" to "service_role";

grant update on table "public"."business_service_subcategories" to "service_role";

grant delete on table "public"."business_services" to "anon";

grant insert on table "public"."business_services" to "anon";

grant references on table "public"."business_services" to "anon";

grant select on table "public"."business_services" to "anon";

grant trigger on table "public"."business_services" to "anon";

grant truncate on table "public"."business_services" to "anon";

grant update on table "public"."business_services" to "anon";

grant delete on table "public"."business_services" to "authenticated";

grant insert on table "public"."business_services" to "authenticated";

grant references on table "public"."business_services" to "authenticated";

grant select on table "public"."business_services" to "authenticated";

grant trigger on table "public"."business_services" to "authenticated";

grant truncate on table "public"."business_services" to "authenticated";

grant update on table "public"."business_services" to "authenticated";

grant delete on table "public"."business_services" to "service_role";

grant insert on table "public"."business_services" to "service_role";

grant references on table "public"."business_services" to "service_role";

grant select on table "public"."business_services" to "service_role";

grant trigger on table "public"."business_services" to "service_role";

grant truncate on table "public"."business_services" to "service_role";

grant update on table "public"."business_services" to "service_role";

grant delete on table "public"."business_setup_progress" to "anon";

grant insert on table "public"."business_setup_progress" to "anon";

grant references on table "public"."business_setup_progress" to "anon";

grant select on table "public"."business_setup_progress" to "anon";

grant trigger on table "public"."business_setup_progress" to "anon";

grant truncate on table "public"."business_setup_progress" to "anon";

grant update on table "public"."business_setup_progress" to "anon";

grant delete on table "public"."business_setup_progress" to "authenticated";

grant insert on table "public"."business_setup_progress" to "authenticated";

grant references on table "public"."business_setup_progress" to "authenticated";

grant select on table "public"."business_setup_progress" to "authenticated";

grant trigger on table "public"."business_setup_progress" to "authenticated";

grant truncate on table "public"."business_setup_progress" to "authenticated";

grant update on table "public"."business_setup_progress" to "authenticated";

grant delete on table "public"."business_setup_progress" to "service_role";

grant insert on table "public"."business_setup_progress" to "service_role";

grant references on table "public"."business_setup_progress" to "service_role";

grant select on table "public"."business_setup_progress" to "service_role";

grant trigger on table "public"."business_setup_progress" to "service_role";

grant truncate on table "public"."business_setup_progress" to "service_role";

grant update on table "public"."business_setup_progress" to "service_role";

grant delete on table "public"."business_stripe_tax_info" to "anon";

grant insert on table "public"."business_stripe_tax_info" to "anon";

grant references on table "public"."business_stripe_tax_info" to "anon";

grant select on table "public"."business_stripe_tax_info" to "anon";

grant trigger on table "public"."business_stripe_tax_info" to "anon";

grant truncate on table "public"."business_stripe_tax_info" to "anon";

grant update on table "public"."business_stripe_tax_info" to "anon";

grant delete on table "public"."business_stripe_tax_info" to "authenticated";

grant insert on table "public"."business_stripe_tax_info" to "authenticated";

grant references on table "public"."business_stripe_tax_info" to "authenticated";

grant select on table "public"."business_stripe_tax_info" to "authenticated";

grant trigger on table "public"."business_stripe_tax_info" to "authenticated";

grant truncate on table "public"."business_stripe_tax_info" to "authenticated";

grant update on table "public"."business_stripe_tax_info" to "authenticated";

grant delete on table "public"."business_stripe_tax_info" to "service_role";

grant insert on table "public"."business_stripe_tax_info" to "service_role";

grant references on table "public"."business_stripe_tax_info" to "service_role";

grant select on table "public"."business_stripe_tax_info" to "service_role";

grant trigger on table "public"."business_stripe_tax_info" to "service_role";

grant truncate on table "public"."business_stripe_tax_info" to "service_role";

grant update on table "public"."business_stripe_tax_info" to "service_role";

grant delete on table "public"."business_subscriptions" to "anon";

grant insert on table "public"."business_subscriptions" to "anon";

grant references on table "public"."business_subscriptions" to "anon";

grant select on table "public"."business_subscriptions" to "anon";

grant trigger on table "public"."business_subscriptions" to "anon";

grant truncate on table "public"."business_subscriptions" to "anon";

grant update on table "public"."business_subscriptions" to "anon";

grant delete on table "public"."business_subscriptions" to "authenticated";

grant insert on table "public"."business_subscriptions" to "authenticated";

grant references on table "public"."business_subscriptions" to "authenticated";

grant select on table "public"."business_subscriptions" to "authenticated";

grant trigger on table "public"."business_subscriptions" to "authenticated";

grant truncate on table "public"."business_subscriptions" to "authenticated";

grant update on table "public"."business_subscriptions" to "authenticated";

grant delete on table "public"."business_subscriptions" to "service_role";

grant insert on table "public"."business_subscriptions" to "service_role";

grant references on table "public"."business_subscriptions" to "service_role";

grant select on table "public"."business_subscriptions" to "service_role";

grant trigger on table "public"."business_subscriptions" to "service_role";

grant truncate on table "public"."business_subscriptions" to "service_role";

grant update on table "public"."business_subscriptions" to "service_role";

grant delete on table "public"."business_verifications" to "anon";

grant insert on table "public"."business_verifications" to "anon";

grant references on table "public"."business_verifications" to "anon";

grant select on table "public"."business_verifications" to "anon";

grant trigger on table "public"."business_verifications" to "anon";

grant truncate on table "public"."business_verifications" to "anon";

grant update on table "public"."business_verifications" to "anon";

grant delete on table "public"."business_verifications" to "authenticated";

grant insert on table "public"."business_verifications" to "authenticated";

grant references on table "public"."business_verifications" to "authenticated";

grant select on table "public"."business_verifications" to "authenticated";

grant trigger on table "public"."business_verifications" to "authenticated";

grant truncate on table "public"."business_verifications" to "authenticated";

grant update on table "public"."business_verifications" to "authenticated";

grant delete on table "public"."business_verifications" to "service_role";

grant insert on table "public"."business_verifications" to "service_role";

grant references on table "public"."business_verifications" to "service_role";

grant select on table "public"."business_verifications" to "service_role";

grant trigger on table "public"."business_verifications" to "service_role";

grant truncate on table "public"."business_verifications" to "service_role";

grant update on table "public"."business_verifications" to "service_role";

grant delete on table "public"."contact_submissions" to "anon";

grant insert on table "public"."contact_submissions" to "anon";

grant references on table "public"."contact_submissions" to "anon";

grant select on table "public"."contact_submissions" to "anon";

grant trigger on table "public"."contact_submissions" to "anon";

grant truncate on table "public"."contact_submissions" to "anon";

grant update on table "public"."contact_submissions" to "anon";

grant delete on table "public"."contact_submissions" to "authenticated";

grant insert on table "public"."contact_submissions" to "authenticated";

grant references on table "public"."contact_submissions" to "authenticated";

grant select on table "public"."contact_submissions" to "authenticated";

grant trigger on table "public"."contact_submissions" to "authenticated";

grant truncate on table "public"."contact_submissions" to "authenticated";

grant update on table "public"."contact_submissions" to "authenticated";

grant delete on table "public"."contact_submissions" to "service_role";

grant insert on table "public"."contact_submissions" to "service_role";

grant references on table "public"."contact_submissions" to "service_role";

grant select on table "public"."contact_submissions" to "service_role";

grant trigger on table "public"."contact_submissions" to "service_role";

grant truncate on table "public"."contact_submissions" to "service_role";

grant update on table "public"."contact_submissions" to "service_role";

grant delete on table "public"."conversation_metadata" to "anon";

grant insert on table "public"."conversation_metadata" to "anon";

grant references on table "public"."conversation_metadata" to "anon";

grant select on table "public"."conversation_metadata" to "anon";

grant trigger on table "public"."conversation_metadata" to "anon";

grant truncate on table "public"."conversation_metadata" to "anon";

grant update on table "public"."conversation_metadata" to "anon";

grant delete on table "public"."conversation_metadata" to "authenticated";

grant insert on table "public"."conversation_metadata" to "authenticated";

grant references on table "public"."conversation_metadata" to "authenticated";

grant select on table "public"."conversation_metadata" to "authenticated";

grant trigger on table "public"."conversation_metadata" to "authenticated";

grant truncate on table "public"."conversation_metadata" to "authenticated";

grant update on table "public"."conversation_metadata" to "authenticated";

grant delete on table "public"."conversation_metadata" to "service_role";

grant insert on table "public"."conversation_metadata" to "service_role";

grant references on table "public"."conversation_metadata" to "service_role";

grant select on table "public"."conversation_metadata" to "service_role";

grant trigger on table "public"."conversation_metadata" to "service_role";

grant truncate on table "public"."conversation_metadata" to "service_role";

grant update on table "public"."conversation_metadata" to "service_role";

grant delete on table "public"."conversation_participants" to "anon";

grant insert on table "public"."conversation_participants" to "anon";

grant references on table "public"."conversation_participants" to "anon";

grant select on table "public"."conversation_participants" to "anon";

grant trigger on table "public"."conversation_participants" to "anon";

grant truncate on table "public"."conversation_participants" to "anon";

grant update on table "public"."conversation_participants" to "anon";

grant delete on table "public"."conversation_participants" to "authenticated";

grant insert on table "public"."conversation_participants" to "authenticated";

grant references on table "public"."conversation_participants" to "authenticated";

grant select on table "public"."conversation_participants" to "authenticated";

grant trigger on table "public"."conversation_participants" to "authenticated";

grant truncate on table "public"."conversation_participants" to "authenticated";

grant update on table "public"."conversation_participants" to "authenticated";

grant delete on table "public"."conversation_participants" to "service_role";

grant insert on table "public"."conversation_participants" to "service_role";

grant references on table "public"."conversation_participants" to "service_role";

grant select on table "public"."conversation_participants" to "service_role";

grant trigger on table "public"."conversation_participants" to "service_role";

grant truncate on table "public"."conversation_participants" to "service_role";

grant update on table "public"."conversation_participants" to "service_role";

grant delete on table "public"."customer_favorite_businesses" to "anon";

grant insert on table "public"."customer_favorite_businesses" to "anon";

grant references on table "public"."customer_favorite_businesses" to "anon";

grant select on table "public"."customer_favorite_businesses" to "anon";

grant trigger on table "public"."customer_favorite_businesses" to "anon";

grant truncate on table "public"."customer_favorite_businesses" to "anon";

grant update on table "public"."customer_favorite_businesses" to "anon";

grant delete on table "public"."customer_favorite_businesses" to "authenticated";

grant insert on table "public"."customer_favorite_businesses" to "authenticated";

grant references on table "public"."customer_favorite_businesses" to "authenticated";

grant select on table "public"."customer_favorite_businesses" to "authenticated";

grant trigger on table "public"."customer_favorite_businesses" to "authenticated";

grant truncate on table "public"."customer_favorite_businesses" to "authenticated";

grant update on table "public"."customer_favorite_businesses" to "authenticated";

grant delete on table "public"."customer_favorite_businesses" to "service_role";

grant insert on table "public"."customer_favorite_businesses" to "service_role";

grant references on table "public"."customer_favorite_businesses" to "service_role";

grant select on table "public"."customer_favorite_businesses" to "service_role";

grant trigger on table "public"."customer_favorite_businesses" to "service_role";

grant truncate on table "public"."customer_favorite_businesses" to "service_role";

grant update on table "public"."customer_favorite_businesses" to "service_role";

grant delete on table "public"."customer_favorite_providers" to "anon";

grant insert on table "public"."customer_favorite_providers" to "anon";

grant references on table "public"."customer_favorite_providers" to "anon";

grant select on table "public"."customer_favorite_providers" to "anon";

grant trigger on table "public"."customer_favorite_providers" to "anon";

grant truncate on table "public"."customer_favorite_providers" to "anon";

grant update on table "public"."customer_favorite_providers" to "anon";

grant delete on table "public"."customer_favorite_providers" to "authenticated";

grant insert on table "public"."customer_favorite_providers" to "authenticated";

grant references on table "public"."customer_favorite_providers" to "authenticated";

grant select on table "public"."customer_favorite_providers" to "authenticated";

grant trigger on table "public"."customer_favorite_providers" to "authenticated";

grant truncate on table "public"."customer_favorite_providers" to "authenticated";

grant update on table "public"."customer_favorite_providers" to "authenticated";

grant delete on table "public"."customer_favorite_providers" to "service_role";

grant insert on table "public"."customer_favorite_providers" to "service_role";

grant references on table "public"."customer_favorite_providers" to "service_role";

grant select on table "public"."customer_favorite_providers" to "service_role";

grant trigger on table "public"."customer_favorite_providers" to "service_role";

grant truncate on table "public"."customer_favorite_providers" to "service_role";

grant update on table "public"."customer_favorite_providers" to "service_role";

grant delete on table "public"."customer_favorite_services" to "anon";

grant insert on table "public"."customer_favorite_services" to "anon";

grant references on table "public"."customer_favorite_services" to "anon";

grant select on table "public"."customer_favorite_services" to "anon";

grant trigger on table "public"."customer_favorite_services" to "anon";

grant truncate on table "public"."customer_favorite_services" to "anon";

grant update on table "public"."customer_favorite_services" to "anon";

grant delete on table "public"."customer_favorite_services" to "authenticated";

grant insert on table "public"."customer_favorite_services" to "authenticated";

grant references on table "public"."customer_favorite_services" to "authenticated";

grant select on table "public"."customer_favorite_services" to "authenticated";

grant trigger on table "public"."customer_favorite_services" to "authenticated";

grant truncate on table "public"."customer_favorite_services" to "authenticated";

grant update on table "public"."customer_favorite_services" to "authenticated";

grant delete on table "public"."customer_favorite_services" to "service_role";

grant insert on table "public"."customer_favorite_services" to "service_role";

grant references on table "public"."customer_favorite_services" to "service_role";

grant select on table "public"."customer_favorite_services" to "service_role";

grant trigger on table "public"."customer_favorite_services" to "service_role";

grant truncate on table "public"."customer_favorite_services" to "service_role";

grant update on table "public"."customer_favorite_services" to "service_role";

grant delete on table "public"."customer_locations" to "anon";

grant insert on table "public"."customer_locations" to "anon";

grant references on table "public"."customer_locations" to "anon";

grant select on table "public"."customer_locations" to "anon";

grant trigger on table "public"."customer_locations" to "anon";

grant truncate on table "public"."customer_locations" to "anon";

grant update on table "public"."customer_locations" to "anon";

grant delete on table "public"."customer_locations" to "authenticated";

grant insert on table "public"."customer_locations" to "authenticated";

grant references on table "public"."customer_locations" to "authenticated";

grant select on table "public"."customer_locations" to "authenticated";

grant trigger on table "public"."customer_locations" to "authenticated";

grant truncate on table "public"."customer_locations" to "authenticated";

grant update on table "public"."customer_locations" to "authenticated";

grant delete on table "public"."customer_locations" to "service_role";

grant insert on table "public"."customer_locations" to "service_role";

grant references on table "public"."customer_locations" to "service_role";

grant select on table "public"."customer_locations" to "service_role";

grant trigger on table "public"."customer_locations" to "service_role";

grant truncate on table "public"."customer_locations" to "service_role";

grant update on table "public"."customer_locations" to "service_role";

grant delete on table "public"."customer_profiles" to "anon";

grant insert on table "public"."customer_profiles" to "anon";

grant references on table "public"."customer_profiles" to "anon";

grant select on table "public"."customer_profiles" to "anon";

grant trigger on table "public"."customer_profiles" to "anon";

grant truncate on table "public"."customer_profiles" to "anon";

grant update on table "public"."customer_profiles" to "anon";

grant delete on table "public"."customer_profiles" to "authenticated";

grant insert on table "public"."customer_profiles" to "authenticated";

grant references on table "public"."customer_profiles" to "authenticated";

grant select on table "public"."customer_profiles" to "authenticated";

grant trigger on table "public"."customer_profiles" to "authenticated";

grant truncate on table "public"."customer_profiles" to "authenticated";

grant update on table "public"."customer_profiles" to "authenticated";

grant delete on table "public"."customer_profiles" to "service_role";

grant insert on table "public"."customer_profiles" to "service_role";

grant references on table "public"."customer_profiles" to "service_role";

grant select on table "public"."customer_profiles" to "service_role";

grant trigger on table "public"."customer_profiles" to "service_role";

grant truncate on table "public"."customer_profiles" to "service_role";

grant update on table "public"."customer_profiles" to "service_role";

grant delete on table "public"."customer_stripe_profiles" to "anon";

grant insert on table "public"."customer_stripe_profiles" to "anon";

grant references on table "public"."customer_stripe_profiles" to "anon";

grant select on table "public"."customer_stripe_profiles" to "anon";

grant trigger on table "public"."customer_stripe_profiles" to "anon";

grant truncate on table "public"."customer_stripe_profiles" to "anon";

grant update on table "public"."customer_stripe_profiles" to "anon";

grant delete on table "public"."customer_stripe_profiles" to "authenticated";

grant insert on table "public"."customer_stripe_profiles" to "authenticated";

grant references on table "public"."customer_stripe_profiles" to "authenticated";

grant select on table "public"."customer_stripe_profiles" to "authenticated";

grant trigger on table "public"."customer_stripe_profiles" to "authenticated";

grant truncate on table "public"."customer_stripe_profiles" to "authenticated";

grant update on table "public"."customer_stripe_profiles" to "authenticated";

grant delete on table "public"."customer_stripe_profiles" to "service_role";

grant insert on table "public"."customer_stripe_profiles" to "service_role";

grant references on table "public"."customer_stripe_profiles" to "service_role";

grant select on table "public"."customer_stripe_profiles" to "service_role";

grant trigger on table "public"."customer_stripe_profiles" to "service_role";

grant truncate on table "public"."customer_stripe_profiles" to "service_role";

grant update on table "public"."customer_stripe_profiles" to "service_role";

grant delete on table "public"."customer_subscriptions" to "anon";

grant insert on table "public"."customer_subscriptions" to "anon";

grant references on table "public"."customer_subscriptions" to "anon";

grant select on table "public"."customer_subscriptions" to "anon";

grant trigger on table "public"."customer_subscriptions" to "anon";

grant truncate on table "public"."customer_subscriptions" to "anon";

grant update on table "public"."customer_subscriptions" to "anon";

grant delete on table "public"."customer_subscriptions" to "authenticated";

grant insert on table "public"."customer_subscriptions" to "authenticated";

grant references on table "public"."customer_subscriptions" to "authenticated";

grant select on table "public"."customer_subscriptions" to "authenticated";

grant trigger on table "public"."customer_subscriptions" to "authenticated";

grant truncate on table "public"."customer_subscriptions" to "authenticated";

grant update on table "public"."customer_subscriptions" to "authenticated";

grant delete on table "public"."customer_subscriptions" to "service_role";

grant insert on table "public"."customer_subscriptions" to "service_role";

grant references on table "public"."customer_subscriptions" to "service_role";

grant select on table "public"."customer_subscriptions" to "service_role";

grant trigger on table "public"."customer_subscriptions" to "service_role";

grant truncate on table "public"."customer_subscriptions" to "service_role";

grant update on table "public"."customer_subscriptions" to "service_role";

grant delete on table "public"."email_logs" to "anon";

grant insert on table "public"."email_logs" to "anon";

grant references on table "public"."email_logs" to "anon";

grant select on table "public"."email_logs" to "anon";

grant trigger on table "public"."email_logs" to "anon";

grant truncate on table "public"."email_logs" to "anon";

grant update on table "public"."email_logs" to "anon";

grant delete on table "public"."email_logs" to "authenticated";

grant insert on table "public"."email_logs" to "authenticated";

grant references on table "public"."email_logs" to "authenticated";

grant select on table "public"."email_logs" to "authenticated";

grant trigger on table "public"."email_logs" to "authenticated";

grant truncate on table "public"."email_logs" to "authenticated";

grant update on table "public"."email_logs" to "authenticated";

grant delete on table "public"."email_logs" to "service_role";

grant insert on table "public"."email_logs" to "service_role";

grant references on table "public"."email_logs" to "service_role";

grant select on table "public"."email_logs" to "service_role";

grant trigger on table "public"."email_logs" to "service_role";

grant truncate on table "public"."email_logs" to "service_role";

grant update on table "public"."email_logs" to "service_role";

grant delete on table "public"."financial_transactions" to "anon";

grant insert on table "public"."financial_transactions" to "anon";

grant references on table "public"."financial_transactions" to "anon";

grant select on table "public"."financial_transactions" to "anon";

grant trigger on table "public"."financial_transactions" to "anon";

grant truncate on table "public"."financial_transactions" to "anon";

grant update on table "public"."financial_transactions" to "anon";

grant delete on table "public"."financial_transactions" to "authenticated";

grant insert on table "public"."financial_transactions" to "authenticated";

grant references on table "public"."financial_transactions" to "authenticated";

grant select on table "public"."financial_transactions" to "authenticated";

grant trigger on table "public"."financial_transactions" to "authenticated";

grant truncate on table "public"."financial_transactions" to "authenticated";

grant update on table "public"."financial_transactions" to "authenticated";

grant delete on table "public"."financial_transactions" to "service_role";

grant insert on table "public"."financial_transactions" to "service_role";

grant references on table "public"."financial_transactions" to "service_role";

grant select on table "public"."financial_transactions" to "service_role";

grant trigger on table "public"."financial_transactions" to "service_role";

grant truncate on table "public"."financial_transactions" to "service_role";

grant update on table "public"."financial_transactions" to "service_role";

grant delete on table "public"."message_analytics" to "anon";

grant insert on table "public"."message_analytics" to "anon";

grant references on table "public"."message_analytics" to "anon";

grant select on table "public"."message_analytics" to "anon";

grant trigger on table "public"."message_analytics" to "anon";

grant truncate on table "public"."message_analytics" to "anon";

grant update on table "public"."message_analytics" to "anon";

grant delete on table "public"."message_analytics" to "authenticated";

grant insert on table "public"."message_analytics" to "authenticated";

grant references on table "public"."message_analytics" to "authenticated";

grant select on table "public"."message_analytics" to "authenticated";

grant trigger on table "public"."message_analytics" to "authenticated";

grant truncate on table "public"."message_analytics" to "authenticated";

grant update on table "public"."message_analytics" to "authenticated";

grant delete on table "public"."message_analytics" to "service_role";

grant insert on table "public"."message_analytics" to "service_role";

grant references on table "public"."message_analytics" to "service_role";

grant select on table "public"."message_analytics" to "service_role";

grant trigger on table "public"."message_analytics" to "service_role";

grant truncate on table "public"."message_analytics" to "service_role";

grant update on table "public"."message_analytics" to "service_role";

grant delete on table "public"."message_notifications" to "anon";

grant insert on table "public"."message_notifications" to "anon";

grant references on table "public"."message_notifications" to "anon";

grant select on table "public"."message_notifications" to "anon";

grant trigger on table "public"."message_notifications" to "anon";

grant truncate on table "public"."message_notifications" to "anon";

grant update on table "public"."message_notifications" to "anon";

grant delete on table "public"."message_notifications" to "authenticated";

grant insert on table "public"."message_notifications" to "authenticated";

grant references on table "public"."message_notifications" to "authenticated";

grant select on table "public"."message_notifications" to "authenticated";

grant trigger on table "public"."message_notifications" to "authenticated";

grant truncate on table "public"."message_notifications" to "authenticated";

grant update on table "public"."message_notifications" to "authenticated";

grant delete on table "public"."message_notifications" to "service_role";

grant insert on table "public"."message_notifications" to "service_role";

grant references on table "public"."message_notifications" to "service_role";

grant select on table "public"."message_notifications" to "service_role";

grant trigger on table "public"."message_notifications" to "service_role";

grant truncate on table "public"."message_notifications" to "service_role";

grant update on table "public"."message_notifications" to "service_role";

grant delete on table "public"."mfa_challenges" to "anon";

grant insert on table "public"."mfa_challenges" to "anon";

grant references on table "public"."mfa_challenges" to "anon";

grant select on table "public"."mfa_challenges" to "anon";

grant trigger on table "public"."mfa_challenges" to "anon";

grant truncate on table "public"."mfa_challenges" to "anon";

grant update on table "public"."mfa_challenges" to "anon";

grant delete on table "public"."mfa_challenges" to "authenticated";

grant insert on table "public"."mfa_challenges" to "authenticated";

grant references on table "public"."mfa_challenges" to "authenticated";

grant select on table "public"."mfa_challenges" to "authenticated";

grant trigger on table "public"."mfa_challenges" to "authenticated";

grant truncate on table "public"."mfa_challenges" to "authenticated";

grant update on table "public"."mfa_challenges" to "authenticated";

grant delete on table "public"."mfa_challenges" to "service_role";

grant insert on table "public"."mfa_challenges" to "service_role";

grant references on table "public"."mfa_challenges" to "service_role";

grant select on table "public"."mfa_challenges" to "service_role";

grant trigger on table "public"."mfa_challenges" to "service_role";

grant truncate on table "public"."mfa_challenges" to "service_role";

grant update on table "public"."mfa_challenges" to "service_role";

grant delete on table "public"."mfa_factors" to "anon";

grant insert on table "public"."mfa_factors" to "anon";

grant references on table "public"."mfa_factors" to "anon";

grant select on table "public"."mfa_factors" to "anon";

grant trigger on table "public"."mfa_factors" to "anon";

grant truncate on table "public"."mfa_factors" to "anon";

grant update on table "public"."mfa_factors" to "anon";

grant delete on table "public"."mfa_factors" to "authenticated";

grant insert on table "public"."mfa_factors" to "authenticated";

grant references on table "public"."mfa_factors" to "authenticated";

grant select on table "public"."mfa_factors" to "authenticated";

grant trigger on table "public"."mfa_factors" to "authenticated";

grant truncate on table "public"."mfa_factors" to "authenticated";

grant update on table "public"."mfa_factors" to "authenticated";

grant delete on table "public"."mfa_factors" to "service_role";

grant insert on table "public"."mfa_factors" to "service_role";

grant references on table "public"."mfa_factors" to "service_role";

grant select on table "public"."mfa_factors" to "service_role";

grant trigger on table "public"."mfa_factors" to "service_role";

grant truncate on table "public"."mfa_factors" to "service_role";

grant update on table "public"."mfa_factors" to "service_role";

grant delete on table "public"."mfa_sessions" to "anon";

grant insert on table "public"."mfa_sessions" to "anon";

grant references on table "public"."mfa_sessions" to "anon";

grant select on table "public"."mfa_sessions" to "anon";

grant trigger on table "public"."mfa_sessions" to "anon";

grant truncate on table "public"."mfa_sessions" to "anon";

grant update on table "public"."mfa_sessions" to "anon";

grant delete on table "public"."mfa_sessions" to "authenticated";

grant insert on table "public"."mfa_sessions" to "authenticated";

grant references on table "public"."mfa_sessions" to "authenticated";

grant select on table "public"."mfa_sessions" to "authenticated";

grant trigger on table "public"."mfa_sessions" to "authenticated";

grant truncate on table "public"."mfa_sessions" to "authenticated";

grant update on table "public"."mfa_sessions" to "authenticated";

grant delete on table "public"."mfa_sessions" to "service_role";

grant insert on table "public"."mfa_sessions" to "service_role";

grant references on table "public"."mfa_sessions" to "service_role";

grant select on table "public"."mfa_sessions" to "service_role";

grant trigger on table "public"."mfa_sessions" to "service_role";

grant truncate on table "public"."mfa_sessions" to "service_role";

grant update on table "public"."mfa_sessions" to "service_role";

grant delete on table "public"."mfa_settings" to "anon";

grant insert on table "public"."mfa_settings" to "anon";

grant references on table "public"."mfa_settings" to "anon";

grant select on table "public"."mfa_settings" to "anon";

grant trigger on table "public"."mfa_settings" to "anon";

grant truncate on table "public"."mfa_settings" to "anon";

grant update on table "public"."mfa_settings" to "anon";

grant delete on table "public"."mfa_settings" to "authenticated";

grant insert on table "public"."mfa_settings" to "authenticated";

grant references on table "public"."mfa_settings" to "authenticated";

grant select on table "public"."mfa_settings" to "authenticated";

grant trigger on table "public"."mfa_settings" to "authenticated";

grant truncate on table "public"."mfa_settings" to "authenticated";

grant update on table "public"."mfa_settings" to "authenticated";

grant delete on table "public"."mfa_settings" to "service_role";

grant insert on table "public"."mfa_settings" to "service_role";

grant references on table "public"."mfa_settings" to "service_role";

grant select on table "public"."mfa_settings" to "service_role";

grant trigger on table "public"."mfa_settings" to "service_role";

grant truncate on table "public"."mfa_settings" to "service_role";

grant update on table "public"."mfa_settings" to "service_role";

grant delete on table "public"."newsletter_subscribers" to "anon";

grant insert on table "public"."newsletter_subscribers" to "anon";

grant references on table "public"."newsletter_subscribers" to "anon";

grant select on table "public"."newsletter_subscribers" to "anon";

grant trigger on table "public"."newsletter_subscribers" to "anon";

grant truncate on table "public"."newsletter_subscribers" to "anon";

grant update on table "public"."newsletter_subscribers" to "anon";

grant delete on table "public"."newsletter_subscribers" to "authenticated";

grant insert on table "public"."newsletter_subscribers" to "authenticated";

grant references on table "public"."newsletter_subscribers" to "authenticated";

grant select on table "public"."newsletter_subscribers" to "authenticated";

grant trigger on table "public"."newsletter_subscribers" to "authenticated";

grant truncate on table "public"."newsletter_subscribers" to "authenticated";

grant update on table "public"."newsletter_subscribers" to "authenticated";

grant delete on table "public"."newsletter_subscribers" to "service_role";

grant insert on table "public"."newsletter_subscribers" to "service_role";

grant references on table "public"."newsletter_subscribers" to "service_role";

grant select on table "public"."newsletter_subscribers" to "service_role";

grant trigger on table "public"."newsletter_subscribers" to "service_role";

grant truncate on table "public"."newsletter_subscribers" to "service_role";

grant update on table "public"."newsletter_subscribers" to "service_role";

grant delete on table "public"."notification_logs" to "anon";

grant insert on table "public"."notification_logs" to "anon";

grant references on table "public"."notification_logs" to "anon";

grant select on table "public"."notification_logs" to "anon";

grant trigger on table "public"."notification_logs" to "anon";

grant truncate on table "public"."notification_logs" to "anon";

grant update on table "public"."notification_logs" to "anon";

grant delete on table "public"."notification_logs" to "authenticated";

grant insert on table "public"."notification_logs" to "authenticated";

grant references on table "public"."notification_logs" to "authenticated";

grant select on table "public"."notification_logs" to "authenticated";

grant trigger on table "public"."notification_logs" to "authenticated";

grant truncate on table "public"."notification_logs" to "authenticated";

grant update on table "public"."notification_logs" to "authenticated";

grant delete on table "public"."notification_logs" to "service_role";

grant insert on table "public"."notification_logs" to "service_role";

grant references on table "public"."notification_logs" to "service_role";

grant select on table "public"."notification_logs" to "service_role";

grant trigger on table "public"."notification_logs" to "service_role";

grant truncate on table "public"."notification_logs" to "service_role";

grant update on table "public"."notification_logs" to "service_role";

grant delete on table "public"."notification_templates" to "anon";

grant insert on table "public"."notification_templates" to "anon";

grant references on table "public"."notification_templates" to "anon";

grant select on table "public"."notification_templates" to "anon";

grant trigger on table "public"."notification_templates" to "anon";

grant truncate on table "public"."notification_templates" to "anon";

grant update on table "public"."notification_templates" to "anon";

grant delete on table "public"."notification_templates" to "authenticated";

grant insert on table "public"."notification_templates" to "authenticated";

grant references on table "public"."notification_templates" to "authenticated";

grant select on table "public"."notification_templates" to "authenticated";

grant trigger on table "public"."notification_templates" to "authenticated";

grant truncate on table "public"."notification_templates" to "authenticated";

grant update on table "public"."notification_templates" to "authenticated";

grant delete on table "public"."notification_templates" to "service_role";

grant insert on table "public"."notification_templates" to "service_role";

grant references on table "public"."notification_templates" to "service_role";

grant select on table "public"."notification_templates" to "service_role";

grant trigger on table "public"."notification_templates" to "service_role";

grant truncate on table "public"."notification_templates" to "service_role";

grant update on table "public"."notification_templates" to "service_role";

grant delete on table "public"."platform_analytics" to "anon";

grant insert on table "public"."platform_analytics" to "anon";

grant references on table "public"."platform_analytics" to "anon";

grant select on table "public"."platform_analytics" to "anon";

grant trigger on table "public"."platform_analytics" to "anon";

grant truncate on table "public"."platform_analytics" to "anon";

grant update on table "public"."platform_analytics" to "anon";

grant delete on table "public"."platform_analytics" to "authenticated";

grant insert on table "public"."platform_analytics" to "authenticated";

grant references on table "public"."platform_analytics" to "authenticated";

grant select on table "public"."platform_analytics" to "authenticated";

grant trigger on table "public"."platform_analytics" to "authenticated";

grant truncate on table "public"."platform_analytics" to "authenticated";

grant update on table "public"."platform_analytics" to "authenticated";

grant delete on table "public"."platform_analytics" to "service_role";

grant insert on table "public"."platform_analytics" to "service_role";

grant references on table "public"."platform_analytics" to "service_role";

grant select on table "public"."platform_analytics" to "service_role";

grant trigger on table "public"."platform_analytics" to "service_role";

grant truncate on table "public"."platform_analytics" to "service_role";

grant update on table "public"."platform_analytics" to "service_role";

grant delete on table "public"."platform_annual_tax_summary" to "anon";

grant insert on table "public"."platform_annual_tax_summary" to "anon";

grant references on table "public"."platform_annual_tax_summary" to "anon";

grant select on table "public"."platform_annual_tax_summary" to "anon";

grant trigger on table "public"."platform_annual_tax_summary" to "anon";

grant truncate on table "public"."platform_annual_tax_summary" to "anon";

grant update on table "public"."platform_annual_tax_summary" to "anon";

grant delete on table "public"."platform_annual_tax_summary" to "authenticated";

grant insert on table "public"."platform_annual_tax_summary" to "authenticated";

grant references on table "public"."platform_annual_tax_summary" to "authenticated";

grant select on table "public"."platform_annual_tax_summary" to "authenticated";

grant trigger on table "public"."platform_annual_tax_summary" to "authenticated";

grant truncate on table "public"."platform_annual_tax_summary" to "authenticated";

grant update on table "public"."platform_annual_tax_summary" to "authenticated";

grant delete on table "public"."platform_annual_tax_summary" to "service_role";

grant insert on table "public"."platform_annual_tax_summary" to "service_role";

grant references on table "public"."platform_annual_tax_summary" to "service_role";

grant select on table "public"."platform_annual_tax_summary" to "service_role";

grant trigger on table "public"."platform_annual_tax_summary" to "service_role";

grant truncate on table "public"."platform_annual_tax_summary" to "service_role";

grant update on table "public"."platform_annual_tax_summary" to "service_role";

grant delete on table "public"."promotion_usage" to "anon";

grant insert on table "public"."promotion_usage" to "anon";

grant references on table "public"."promotion_usage" to "anon";

grant select on table "public"."promotion_usage" to "anon";

grant trigger on table "public"."promotion_usage" to "anon";

grant truncate on table "public"."promotion_usage" to "anon";

grant update on table "public"."promotion_usage" to "anon";

grant delete on table "public"."promotion_usage" to "authenticated";

grant insert on table "public"."promotion_usage" to "authenticated";

grant references on table "public"."promotion_usage" to "authenticated";

grant select on table "public"."promotion_usage" to "authenticated";

grant trigger on table "public"."promotion_usage" to "authenticated";

grant truncate on table "public"."promotion_usage" to "authenticated";

grant update on table "public"."promotion_usage" to "authenticated";

grant delete on table "public"."promotion_usage" to "service_role";

grant insert on table "public"."promotion_usage" to "service_role";

grant references on table "public"."promotion_usage" to "service_role";

grant select on table "public"."promotion_usage" to "service_role";

grant trigger on table "public"."promotion_usage" to "service_role";

grant truncate on table "public"."promotion_usage" to "service_role";

grant update on table "public"."promotion_usage" to "service_role";

grant delete on table "public"."promotions" to "anon";

grant insert on table "public"."promotions" to "anon";

grant references on table "public"."promotions" to "anon";

grant select on table "public"."promotions" to "anon";

grant trigger on table "public"."promotions" to "anon";

grant truncate on table "public"."promotions" to "anon";

grant update on table "public"."promotions" to "anon";

grant delete on table "public"."promotions" to "authenticated";

grant insert on table "public"."promotions" to "authenticated";

grant references on table "public"."promotions" to "authenticated";

grant select on table "public"."promotions" to "authenticated";

grant trigger on table "public"."promotions" to "authenticated";

grant truncate on table "public"."promotions" to "authenticated";

grant update on table "public"."promotions" to "authenticated";

grant delete on table "public"."promotions" to "service_role";

grant insert on table "public"."promotions" to "service_role";

grant references on table "public"."promotions" to "service_role";

grant select on table "public"."promotions" to "service_role";

grant trigger on table "public"."promotions" to "service_role";

grant truncate on table "public"."promotions" to "service_role";

grant update on table "public"."promotions" to "service_role";

grant delete on table "public"."provider_addons" to "anon";

grant insert on table "public"."provider_addons" to "anon";

grant references on table "public"."provider_addons" to "anon";

grant select on table "public"."provider_addons" to "anon";

grant trigger on table "public"."provider_addons" to "anon";

grant truncate on table "public"."provider_addons" to "anon";

grant update on table "public"."provider_addons" to "anon";

grant delete on table "public"."provider_addons" to "authenticated";

grant insert on table "public"."provider_addons" to "authenticated";

grant references on table "public"."provider_addons" to "authenticated";

grant select on table "public"."provider_addons" to "authenticated";

grant trigger on table "public"."provider_addons" to "authenticated";

grant truncate on table "public"."provider_addons" to "authenticated";

grant update on table "public"."provider_addons" to "authenticated";

grant delete on table "public"."provider_addons" to "service_role";

grant insert on table "public"."provider_addons" to "service_role";

grant references on table "public"."provider_addons" to "service_role";

grant select on table "public"."provider_addons" to "service_role";

grant trigger on table "public"."provider_addons" to "service_role";

grant truncate on table "public"."provider_addons" to "service_role";

grant update on table "public"."provider_addons" to "service_role";

grant delete on table "public"."provider_applications" to "anon";

grant insert on table "public"."provider_applications" to "anon";

grant references on table "public"."provider_applications" to "anon";

grant select on table "public"."provider_applications" to "anon";

grant trigger on table "public"."provider_applications" to "anon";

grant truncate on table "public"."provider_applications" to "anon";

grant update on table "public"."provider_applications" to "anon";

grant delete on table "public"."provider_applications" to "authenticated";

grant insert on table "public"."provider_applications" to "authenticated";

grant references on table "public"."provider_applications" to "authenticated";

grant select on table "public"."provider_applications" to "authenticated";

grant trigger on table "public"."provider_applications" to "authenticated";

grant truncate on table "public"."provider_applications" to "authenticated";

grant update on table "public"."provider_applications" to "authenticated";

grant delete on table "public"."provider_applications" to "service_role";

grant insert on table "public"."provider_applications" to "service_role";

grant references on table "public"."provider_applications" to "service_role";

grant select on table "public"."provider_applications" to "service_role";

grant trigger on table "public"."provider_applications" to "service_role";

grant truncate on table "public"."provider_applications" to "service_role";

grant update on table "public"."provider_applications" to "service_role";

grant delete on table "public"."provider_availability" to "anon";

grant insert on table "public"."provider_availability" to "anon";

grant references on table "public"."provider_availability" to "anon";

grant select on table "public"."provider_availability" to "anon";

grant trigger on table "public"."provider_availability" to "anon";

grant truncate on table "public"."provider_availability" to "anon";

grant update on table "public"."provider_availability" to "anon";

grant delete on table "public"."provider_availability" to "authenticated";

grant insert on table "public"."provider_availability" to "authenticated";

grant references on table "public"."provider_availability" to "authenticated";

grant select on table "public"."provider_availability" to "authenticated";

grant trigger on table "public"."provider_availability" to "authenticated";

grant truncate on table "public"."provider_availability" to "authenticated";

grant update on table "public"."provider_availability" to "authenticated";

grant delete on table "public"."provider_availability" to "service_role";

grant insert on table "public"."provider_availability" to "service_role";

grant references on table "public"."provider_availability" to "service_role";

grant select on table "public"."provider_availability" to "service_role";

grant trigger on table "public"."provider_availability" to "service_role";

grant truncate on table "public"."provider_availability" to "service_role";

grant update on table "public"."provider_availability" to "service_role";

grant delete on table "public"."provider_availability_exceptions" to "anon";

grant insert on table "public"."provider_availability_exceptions" to "anon";

grant references on table "public"."provider_availability_exceptions" to "anon";

grant select on table "public"."provider_availability_exceptions" to "anon";

grant trigger on table "public"."provider_availability_exceptions" to "anon";

grant truncate on table "public"."provider_availability_exceptions" to "anon";

grant update on table "public"."provider_availability_exceptions" to "anon";

grant delete on table "public"."provider_availability_exceptions" to "authenticated";

grant insert on table "public"."provider_availability_exceptions" to "authenticated";

grant references on table "public"."provider_availability_exceptions" to "authenticated";

grant select on table "public"."provider_availability_exceptions" to "authenticated";

grant trigger on table "public"."provider_availability_exceptions" to "authenticated";

grant truncate on table "public"."provider_availability_exceptions" to "authenticated";

grant update on table "public"."provider_availability_exceptions" to "authenticated";

grant delete on table "public"."provider_availability_exceptions" to "service_role";

grant insert on table "public"."provider_availability_exceptions" to "service_role";

grant references on table "public"."provider_availability_exceptions" to "service_role";

grant select on table "public"."provider_availability_exceptions" to "service_role";

grant trigger on table "public"."provider_availability_exceptions" to "service_role";

grant truncate on table "public"."provider_availability_exceptions" to "service_role";

grant update on table "public"."provider_availability_exceptions" to "service_role";

grant delete on table "public"."provider_booking_preferences" to "anon";

grant insert on table "public"."provider_booking_preferences" to "anon";

grant references on table "public"."provider_booking_preferences" to "anon";

grant select on table "public"."provider_booking_preferences" to "anon";

grant trigger on table "public"."provider_booking_preferences" to "anon";

grant truncate on table "public"."provider_booking_preferences" to "anon";

grant update on table "public"."provider_booking_preferences" to "anon";

grant delete on table "public"."provider_booking_preferences" to "authenticated";

grant insert on table "public"."provider_booking_preferences" to "authenticated";

grant references on table "public"."provider_booking_preferences" to "authenticated";

grant select on table "public"."provider_booking_preferences" to "authenticated";

grant trigger on table "public"."provider_booking_preferences" to "authenticated";

grant truncate on table "public"."provider_booking_preferences" to "authenticated";

grant update on table "public"."provider_booking_preferences" to "authenticated";

grant delete on table "public"."provider_booking_preferences" to "service_role";

grant insert on table "public"."provider_booking_preferences" to "service_role";

grant references on table "public"."provider_booking_preferences" to "service_role";

grant select on table "public"."provider_booking_preferences" to "service_role";

grant trigger on table "public"."provider_booking_preferences" to "service_role";

grant truncate on table "public"."provider_booking_preferences" to "service_role";

grant update on table "public"."provider_booking_preferences" to "service_role";

grant delete on table "public"."provider_services" to "anon";

grant insert on table "public"."provider_services" to "anon";

grant references on table "public"."provider_services" to "anon";

grant select on table "public"."provider_services" to "anon";

grant trigger on table "public"."provider_services" to "anon";

grant truncate on table "public"."provider_services" to "anon";

grant update on table "public"."provider_services" to "anon";

grant delete on table "public"."provider_services" to "authenticated";

grant insert on table "public"."provider_services" to "authenticated";

grant references on table "public"."provider_services" to "authenticated";

grant select on table "public"."provider_services" to "authenticated";

grant trigger on table "public"."provider_services" to "authenticated";

grant truncate on table "public"."provider_services" to "authenticated";

grant update on table "public"."provider_services" to "authenticated";

grant delete on table "public"."provider_services" to "service_role";

grant insert on table "public"."provider_services" to "service_role";

grant references on table "public"."provider_services" to "service_role";

grant select on table "public"."provider_services" to "service_role";

grant trigger on table "public"."provider_services" to "service_role";

grant truncate on table "public"."provider_services" to "service_role";

grant update on table "public"."provider_services" to "service_role";

grant delete on table "public"."providers" to "anon";

grant insert on table "public"."providers" to "anon";

grant references on table "public"."providers" to "anon";

grant select on table "public"."providers" to "anon";

grant trigger on table "public"."providers" to "anon";

grant truncate on table "public"."providers" to "anon";

grant update on table "public"."providers" to "anon";

grant delete on table "public"."providers" to "authenticated";

grant insert on table "public"."providers" to "authenticated";

grant references on table "public"."providers" to "authenticated";

grant select on table "public"."providers" to "authenticated";

grant trigger on table "public"."providers" to "authenticated";

grant truncate on table "public"."providers" to "authenticated";

grant update on table "public"."providers" to "authenticated";

grant delete on table "public"."providers" to "service_role";

grant insert on table "public"."providers" to "service_role";

grant references on table "public"."providers" to "service_role";

grant select on table "public"."providers" to "service_role";

grant trigger on table "public"."providers" to "service_role";

grant truncate on table "public"."providers" to "service_role";

grant update on table "public"."providers" to "service_role";

grant delete on table "public"."reviews" to "anon";

grant insert on table "public"."reviews" to "anon";

grant references on table "public"."reviews" to "anon";

grant select on table "public"."reviews" to "anon";

grant trigger on table "public"."reviews" to "anon";

grant truncate on table "public"."reviews" to "anon";

grant update on table "public"."reviews" to "anon";

grant delete on table "public"."reviews" to "authenticated";

grant insert on table "public"."reviews" to "authenticated";

grant references on table "public"."reviews" to "authenticated";

grant select on table "public"."reviews" to "authenticated";

grant trigger on table "public"."reviews" to "authenticated";

grant truncate on table "public"."reviews" to "authenticated";

grant update on table "public"."reviews" to "authenticated";

grant delete on table "public"."reviews" to "service_role";

grant insert on table "public"."reviews" to "service_role";

grant references on table "public"."reviews" to "service_role";

grant select on table "public"."reviews" to "service_role";

grant trigger on table "public"."reviews" to "service_role";

grant truncate on table "public"."reviews" to "service_role";

grant update on table "public"."reviews" to "service_role";

grant delete on table "public"."service_addon_eligibility" to "anon";

grant insert on table "public"."service_addon_eligibility" to "anon";

grant references on table "public"."service_addon_eligibility" to "anon";

grant select on table "public"."service_addon_eligibility" to "anon";

grant trigger on table "public"."service_addon_eligibility" to "anon";

grant truncate on table "public"."service_addon_eligibility" to "anon";

grant update on table "public"."service_addon_eligibility" to "anon";

grant delete on table "public"."service_addon_eligibility" to "authenticated";

grant insert on table "public"."service_addon_eligibility" to "authenticated";

grant references on table "public"."service_addon_eligibility" to "authenticated";

grant select on table "public"."service_addon_eligibility" to "authenticated";

grant trigger on table "public"."service_addon_eligibility" to "authenticated";

grant truncate on table "public"."service_addon_eligibility" to "authenticated";

grant update on table "public"."service_addon_eligibility" to "authenticated";

grant delete on table "public"."service_addon_eligibility" to "service_role";

grant insert on table "public"."service_addon_eligibility" to "service_role";

grant references on table "public"."service_addon_eligibility" to "service_role";

grant select on table "public"."service_addon_eligibility" to "service_role";

grant trigger on table "public"."service_addon_eligibility" to "service_role";

grant truncate on table "public"."service_addon_eligibility" to "service_role";

grant update on table "public"."service_addon_eligibility" to "service_role";

grant delete on table "public"."service_addons" to "anon";

grant insert on table "public"."service_addons" to "anon";

grant references on table "public"."service_addons" to "anon";

grant select on table "public"."service_addons" to "anon";

grant trigger on table "public"."service_addons" to "anon";

grant truncate on table "public"."service_addons" to "anon";

grant update on table "public"."service_addons" to "anon";

grant delete on table "public"."service_addons" to "authenticated";

grant insert on table "public"."service_addons" to "authenticated";

grant references on table "public"."service_addons" to "authenticated";

grant select on table "public"."service_addons" to "authenticated";

grant trigger on table "public"."service_addons" to "authenticated";

grant truncate on table "public"."service_addons" to "authenticated";

grant update on table "public"."service_addons" to "authenticated";

grant delete on table "public"."service_addons" to "service_role";

grant insert on table "public"."service_addons" to "service_role";

grant references on table "public"."service_addons" to "service_role";

grant select on table "public"."service_addons" to "service_role";

grant trigger on table "public"."service_addons" to "service_role";

grant truncate on table "public"."service_addons" to "service_role";

grant update on table "public"."service_addons" to "service_role";

grant delete on table "public"."service_categories" to "anon";

grant insert on table "public"."service_categories" to "anon";

grant references on table "public"."service_categories" to "anon";

grant select on table "public"."service_categories" to "anon";

grant trigger on table "public"."service_categories" to "anon";

grant truncate on table "public"."service_categories" to "anon";

grant update on table "public"."service_categories" to "anon";

grant delete on table "public"."service_categories" to "authenticated";

grant insert on table "public"."service_categories" to "authenticated";

grant references on table "public"."service_categories" to "authenticated";

grant select on table "public"."service_categories" to "authenticated";

grant trigger on table "public"."service_categories" to "authenticated";

grant truncate on table "public"."service_categories" to "authenticated";

grant update on table "public"."service_categories" to "authenticated";

grant delete on table "public"."service_categories" to "service_role";

grant insert on table "public"."service_categories" to "service_role";

grant references on table "public"."service_categories" to "service_role";

grant select on table "public"."service_categories" to "service_role";

grant trigger on table "public"."service_categories" to "service_role";

grant truncate on table "public"."service_categories" to "service_role";

grant update on table "public"."service_categories" to "service_role";

grant delete on table "public"."service_subcategories" to "anon";

grant insert on table "public"."service_subcategories" to "anon";

grant references on table "public"."service_subcategories" to "anon";

grant select on table "public"."service_subcategories" to "anon";

grant trigger on table "public"."service_subcategories" to "anon";

grant truncate on table "public"."service_subcategories" to "anon";

grant update on table "public"."service_subcategories" to "anon";

grant delete on table "public"."service_subcategories" to "authenticated";

grant insert on table "public"."service_subcategories" to "authenticated";

grant references on table "public"."service_subcategories" to "authenticated";

grant select on table "public"."service_subcategories" to "authenticated";

grant trigger on table "public"."service_subcategories" to "authenticated";

grant truncate on table "public"."service_subcategories" to "authenticated";

grant update on table "public"."service_subcategories" to "authenticated";

grant delete on table "public"."service_subcategories" to "service_role";

grant insert on table "public"."service_subcategories" to "service_role";

grant references on table "public"."service_subcategories" to "service_role";

grant select on table "public"."service_subcategories" to "service_role";

grant trigger on table "public"."service_subcategories" to "service_role";

grant truncate on table "public"."service_subcategories" to "service_role";

grant update on table "public"."service_subcategories" to "service_role";

grant delete on table "public"."services" to "anon";

grant insert on table "public"."services" to "anon";

grant references on table "public"."services" to "anon";

grant select on table "public"."services" to "anon";

grant trigger on table "public"."services" to "anon";

grant truncate on table "public"."services" to "anon";

grant update on table "public"."services" to "anon";

grant delete on table "public"."services" to "authenticated";

grant insert on table "public"."services" to "authenticated";

grant references on table "public"."services" to "authenticated";

grant select on table "public"."services" to "authenticated";

grant trigger on table "public"."services" to "authenticated";

grant truncate on table "public"."services" to "authenticated";

grant update on table "public"."services" to "authenticated";

grant delete on table "public"."services" to "service_role";

grant insert on table "public"."services" to "service_role";

grant references on table "public"."services" to "service_role";

grant select on table "public"."services" to "service_role";

grant trigger on table "public"."services" to "service_role";

grant truncate on table "public"."services" to "service_role";

grant update on table "public"."services" to "service_role";

grant delete on table "public"."stripe_connect_accounts" to "anon";

grant insert on table "public"."stripe_connect_accounts" to "anon";

grant references on table "public"."stripe_connect_accounts" to "anon";

grant select on table "public"."stripe_connect_accounts" to "anon";

grant trigger on table "public"."stripe_connect_accounts" to "anon";

grant truncate on table "public"."stripe_connect_accounts" to "anon";

grant update on table "public"."stripe_connect_accounts" to "anon";

grant delete on table "public"."stripe_connect_accounts" to "authenticated";

grant insert on table "public"."stripe_connect_accounts" to "authenticated";

grant references on table "public"."stripe_connect_accounts" to "authenticated";

grant select on table "public"."stripe_connect_accounts" to "authenticated";

grant trigger on table "public"."stripe_connect_accounts" to "authenticated";

grant truncate on table "public"."stripe_connect_accounts" to "authenticated";

grant update on table "public"."stripe_connect_accounts" to "authenticated";

grant delete on table "public"."stripe_connect_accounts" to "service_role";

grant insert on table "public"."stripe_connect_accounts" to "service_role";

grant references on table "public"."stripe_connect_accounts" to "service_role";

grant select on table "public"."stripe_connect_accounts" to "service_role";

grant trigger on table "public"."stripe_connect_accounts" to "service_role";

grant truncate on table "public"."stripe_connect_accounts" to "service_role";

grant update on table "public"."stripe_connect_accounts" to "service_role";

grant delete on table "public"."stripe_identity_verifications" to "anon";

grant insert on table "public"."stripe_identity_verifications" to "anon";

grant references on table "public"."stripe_identity_verifications" to "anon";

grant select on table "public"."stripe_identity_verifications" to "anon";

grant trigger on table "public"."stripe_identity_verifications" to "anon";

grant truncate on table "public"."stripe_identity_verifications" to "anon";

grant update on table "public"."stripe_identity_verifications" to "anon";

grant delete on table "public"."stripe_identity_verifications" to "authenticated";

grant insert on table "public"."stripe_identity_verifications" to "authenticated";

grant references on table "public"."stripe_identity_verifications" to "authenticated";

grant select on table "public"."stripe_identity_verifications" to "authenticated";

grant trigger on table "public"."stripe_identity_verifications" to "authenticated";

grant truncate on table "public"."stripe_identity_verifications" to "authenticated";

grant update on table "public"."stripe_identity_verifications" to "authenticated";

grant delete on table "public"."stripe_identity_verifications" to "service_role";

grant insert on table "public"."stripe_identity_verifications" to "service_role";

grant references on table "public"."stripe_identity_verifications" to "service_role";

grant select on table "public"."stripe_identity_verifications" to "service_role";

grant trigger on table "public"."stripe_identity_verifications" to "service_role";

grant truncate on table "public"."stripe_identity_verifications" to "service_role";

grant update on table "public"."stripe_identity_verifications" to "service_role";

grant delete on table "public"."stripe_tax_webhook_events" to "anon";

grant insert on table "public"."stripe_tax_webhook_events" to "anon";

grant references on table "public"."stripe_tax_webhook_events" to "anon";

grant select on table "public"."stripe_tax_webhook_events" to "anon";

grant trigger on table "public"."stripe_tax_webhook_events" to "anon";

grant truncate on table "public"."stripe_tax_webhook_events" to "anon";

grant update on table "public"."stripe_tax_webhook_events" to "anon";

grant delete on table "public"."stripe_tax_webhook_events" to "authenticated";

grant insert on table "public"."stripe_tax_webhook_events" to "authenticated";

grant references on table "public"."stripe_tax_webhook_events" to "authenticated";

grant select on table "public"."stripe_tax_webhook_events" to "authenticated";

grant trigger on table "public"."stripe_tax_webhook_events" to "authenticated";

grant truncate on table "public"."stripe_tax_webhook_events" to "authenticated";

grant update on table "public"."stripe_tax_webhook_events" to "authenticated";

grant delete on table "public"."stripe_tax_webhook_events" to "service_role";

grant insert on table "public"."stripe_tax_webhook_events" to "service_role";

grant references on table "public"."stripe_tax_webhook_events" to "service_role";

grant select on table "public"."stripe_tax_webhook_events" to "service_role";

grant trigger on table "public"."stripe_tax_webhook_events" to "service_role";

grant truncate on table "public"."stripe_tax_webhook_events" to "service_role";

grant update on table "public"."stripe_tax_webhook_events" to "service_role";

grant delete on table "public"."system_config" to "anon";

grant insert on table "public"."system_config" to "anon";

grant references on table "public"."system_config" to "anon";

grant select on table "public"."system_config" to "anon";

grant trigger on table "public"."system_config" to "anon";

grant truncate on table "public"."system_config" to "anon";

grant update on table "public"."system_config" to "anon";

grant delete on table "public"."system_config" to "authenticated";

grant insert on table "public"."system_config" to "authenticated";

grant references on table "public"."system_config" to "authenticated";

grant select on table "public"."system_config" to "authenticated";

grant trigger on table "public"."system_config" to "authenticated";

grant truncate on table "public"."system_config" to "authenticated";

grant update on table "public"."system_config" to "authenticated";

grant delete on table "public"."system_config" to "service_role";

grant insert on table "public"."system_config" to "service_role";

grant references on table "public"."system_config" to "service_role";

grant select on table "public"."system_config" to "service_role";

grant trigger on table "public"."system_config" to "service_role";

grant truncate on table "public"."system_config" to "service_role";

grant update on table "public"."system_config" to "service_role";

grant delete on table "public"."tip_analytics_daily" to "anon";

grant insert on table "public"."tip_analytics_daily" to "anon";

grant references on table "public"."tip_analytics_daily" to "anon";

grant select on table "public"."tip_analytics_daily" to "anon";

grant trigger on table "public"."tip_analytics_daily" to "anon";

grant truncate on table "public"."tip_analytics_daily" to "anon";

grant update on table "public"."tip_analytics_daily" to "anon";

grant delete on table "public"."tip_analytics_daily" to "authenticated";

grant insert on table "public"."tip_analytics_daily" to "authenticated";

grant references on table "public"."tip_analytics_daily" to "authenticated";

grant select on table "public"."tip_analytics_daily" to "authenticated";

grant trigger on table "public"."tip_analytics_daily" to "authenticated";

grant truncate on table "public"."tip_analytics_daily" to "authenticated";

grant update on table "public"."tip_analytics_daily" to "authenticated";

grant delete on table "public"."tip_analytics_daily" to "service_role";

grant insert on table "public"."tip_analytics_daily" to "service_role";

grant references on table "public"."tip_analytics_daily" to "service_role";

grant select on table "public"."tip_analytics_daily" to "service_role";

grant trigger on table "public"."tip_analytics_daily" to "service_role";

grant truncate on table "public"."tip_analytics_daily" to "service_role";

grant update on table "public"."tip_analytics_daily" to "service_role";

grant delete on table "public"."tip_presets" to "anon";

grant insert on table "public"."tip_presets" to "anon";

grant references on table "public"."tip_presets" to "anon";

grant select on table "public"."tip_presets" to "anon";

grant trigger on table "public"."tip_presets" to "anon";

grant truncate on table "public"."tip_presets" to "anon";

grant update on table "public"."tip_presets" to "anon";

grant delete on table "public"."tip_presets" to "authenticated";

grant insert on table "public"."tip_presets" to "authenticated";

grant references on table "public"."tip_presets" to "authenticated";

grant select on table "public"."tip_presets" to "authenticated";

grant trigger on table "public"."tip_presets" to "authenticated";

grant truncate on table "public"."tip_presets" to "authenticated";

grant update on table "public"."tip_presets" to "authenticated";

grant delete on table "public"."tip_presets" to "service_role";

grant insert on table "public"."tip_presets" to "service_role";

grant references on table "public"."tip_presets" to "service_role";

grant select on table "public"."tip_presets" to "service_role";

grant trigger on table "public"."tip_presets" to "service_role";

grant truncate on table "public"."tip_presets" to "service_role";

grant update on table "public"."tip_presets" to "service_role";

grant delete on table "public"."tips" to "anon";

grant insert on table "public"."tips" to "anon";

grant references on table "public"."tips" to "anon";

grant select on table "public"."tips" to "anon";

grant trigger on table "public"."tips" to "anon";

grant truncate on table "public"."tips" to "anon";

grant update on table "public"."tips" to "anon";

grant delete on table "public"."tips" to "authenticated";

grant insert on table "public"."tips" to "authenticated";

grant references on table "public"."tips" to "authenticated";

grant select on table "public"."tips" to "authenticated";

grant trigger on table "public"."tips" to "authenticated";

grant truncate on table "public"."tips" to "authenticated";

grant update on table "public"."tips" to "authenticated";

grant delete on table "public"."tips" to "service_role";

grant insert on table "public"."tips" to "service_role";

grant references on table "public"."tips" to "service_role";

grant select on table "public"."tips" to "service_role";

grant trigger on table "public"."tips" to "service_role";

grant truncate on table "public"."tips" to "service_role";

grant update on table "public"."tips" to "service_role";

grant delete on table "public"."user_settings" to "anon";

grant insert on table "public"."user_settings" to "anon";

grant references on table "public"."user_settings" to "anon";

grant select on table "public"."user_settings" to "anon";

grant trigger on table "public"."user_settings" to "anon";

grant truncate on table "public"."user_settings" to "anon";

grant update on table "public"."user_settings" to "anon";

grant delete on table "public"."user_settings" to "authenticated";

grant insert on table "public"."user_settings" to "authenticated";

grant references on table "public"."user_settings" to "authenticated";

grant select on table "public"."user_settings" to "authenticated";

grant trigger on table "public"."user_settings" to "authenticated";

grant truncate on table "public"."user_settings" to "authenticated";

grant update on table "public"."user_settings" to "authenticated";

grant delete on table "public"."user_settings" to "service_role";

grant insert on table "public"."user_settings" to "service_role";

grant references on table "public"."user_settings" to "service_role";

grant select on table "public"."user_settings" to "service_role";

grant trigger on table "public"."user_settings" to "service_role";

grant truncate on table "public"."user_settings" to "service_role";

grant update on table "public"."user_settings" to "service_role";

create policy "Allow anon read access"
on "public"."announcements"
as permissive
for select
to public
using (true);


create policy "Allow anon read access"
on "public"."booking_addons"
as permissive
for select
to public
using (true);


create policy "Allow anon read access"
on "public"."booking_changes"
as permissive
for select
to public
using (true);


create policy "Allow anon read access"
on "public"."bookings"
as permissive
for select
to public
using (true);


create policy "Business owners can view their business bookings"
on "public"."bookings"
as permissive
for select
to public
using ((auth.uid() IN ( SELECT providers.user_id
   FROM providers
  WHERE (providers.business_id IN ( SELECT providers_1.business_id
           FROM providers providers_1
          WHERE (providers_1.id = bookings.provider_id))))));


create policy "Customers can view their own bookings"
on "public"."bookings"
as permissive
for select
to public
using ((auth.uid() IN ( SELECT customer_profiles.user_id
   FROM customer_profiles
  WHERE (customer_profiles.id = bookings.customer_id))));


create policy "Providers can view their assigned bookings"
on "public"."bookings"
as permissive
for select
to public
using ((auth.uid() IN ( SELECT providers.user_id
   FROM providers
  WHERE (providers.id = bookings.provider_id))));


create policy "Service role can access all bookings"
on "public"."bookings"
as permissive
for all
to public
using (((auth.jwt() ->> 'role'::text) = 'service_role'::text));


create policy "business_owners_annual_tax_access"
on "public"."business_annual_tax_tracking"
as permissive
for all
to public
using ((business_id IN ( SELECT providers.business_id
   FROM providers
  WHERE ((providers.user_id = auth.uid()) AND (providers.provider_role = 'owner'::provider_role) AND (providers.is_active = true)))));


create policy "Allow anon read access"
on "public"."business_locations"
as permissive
for select
to public
using (true);


create policy "business_owners_payment_transactions_access"
on "public"."business_payment_transactions"
as permissive
for all
to public
using ((business_id IN ( SELECT providers.business_id
   FROM providers
  WHERE ((providers.user_id = auth.uid()) AND (providers.provider_role = 'owner'::provider_role) AND (providers.is_active = true)))));


create policy "Anyone can view active businesses"
on "public"."business_profiles"
as permissive
for select
to public
using ((is_active = true));


create policy "Business owners can update their own business"
on "public"."business_profiles"
as permissive
for update
to public
using (((auth.jwt() ->> 'business_id'::text) = (id)::text));


create policy "Service role can access all businesses"
on "public"."business_profiles"
as permissive
for all
to public
using (((auth.jwt() ->> 'role'::text) = 'service_role'::text));


create policy "Admins have full access to service categories"
on "public"."business_service_categories"
as permissive
for all
to public
using ((EXISTS ( SELECT 1
   FROM auth.users
  WHERE ((auth.uid() = users.id) AND ((users.raw_user_meta_data ->> 'role'::text) = 'admin'::text)))));


create policy "Business owners can manage their service categories"
on "public"."business_service_categories"
as permissive
for all
to public
using ((business_id IN ( SELECT providers.business_id
   FROM providers
  WHERE ((providers.user_id = auth.uid()) AND (providers.provider_role = ANY (ARRAY['owner'::provider_role, 'dispatcher'::provider_role])) AND (providers.is_active = true)))));


create policy "Public can view active service categories"
on "public"."business_service_categories"
as permissive
for select
to public
using ((is_active = true));


create policy "Admins have full access to service subcategories"
on "public"."business_service_subcategories"
as permissive
for all
to public
using ((EXISTS ( SELECT 1
   FROM auth.users
  WHERE ((auth.uid() = users.id) AND ((users.raw_user_meta_data ->> 'role'::text) = 'admin'::text)))));


create policy "Business owners can manage their service subcategories"
on "public"."business_service_subcategories"
as permissive
for all
to public
using ((business_id IN ( SELECT providers.business_id
   FROM providers
  WHERE ((providers.user_id = auth.uid()) AND (providers.provider_role = ANY (ARRAY['owner'::provider_role, 'dispatcher'::provider_role])) AND (providers.is_active = true)))));


create policy "Public can view active service subcategories"
on "public"."business_service_subcategories"
as permissive
for select
to public
using ((is_active = true));


create policy "Admin can update contact submissions"
on "public"."contact_submissions"
as permissive
for update
to public
using ((((auth.jwt() ->> 'role'::text) = 'admin'::text) OR ((auth.jwt() ->> 'email'::text) = ANY (ARRAY['alan@roamyourbestlife.com'::text, 'admin@roamyourbestlife.com'::text]))));


create policy "Admin can view contact submissions"
on "public"."contact_submissions"
as permissive
for select
to public
using ((((auth.jwt() ->> 'role'::text) = 'admin'::text) OR ((auth.jwt() ->> 'email'::text) = ANY (ARRAY['alan@roamyourbestlife.com'::text, 'admin@roamyourbestlife.com'::text]))));


create policy "Service role can insert contact submissions"
on "public"."contact_submissions"
as permissive
for insert
to public
with check (true);


create policy "Users can insert themselves as participants"
on "public"."conversation_participants"
as permissive
for insert
to public
with check ((user_id = auth.uid()));


create policy "Users can update their own participation"
on "public"."conversation_participants"
as permissive
for update
to public
using ((user_id = auth.uid()));


create policy "Users can view participants for their conversations"
on "public"."conversation_participants"
as permissive
for select
to public
using ((conversation_id IN ( SELECT conversation_metadata.id
   FROM conversation_metadata
  WHERE (conversation_metadata.booking_id IN ( SELECT bookings.id
           FROM bookings
          WHERE ((bookings.customer_id = auth.uid()) OR (bookings.provider_id IN ( SELECT providers.id
                   FROM providers
                  WHERE (providers.user_id = auth.uid()))) OR (bookings.business_id IN ( SELECT providers.business_id
                   FROM providers
                  WHERE (providers.user_id = auth.uid())))))))));


create policy "Users can view participants in their conversations"
on "public"."conversation_participants"
as permissive
for select
to public
using ((EXISTS ( SELECT 1
   FROM conversation_participants cp2
  WHERE ((cp2.conversation_id = conversation_participants.conversation_id) AND (cp2.user_id = auth.uid()) AND (cp2.is_active = true)))));


create policy "Customers can manage their own favorite businesses"
on "public"."customer_favorite_businesses"
as permissive
for all
to authenticated
using ((customer_id = ( SELECT customer_profiles.id
   FROM customer_profiles
  WHERE (customer_profiles.user_id = auth.uid()))))
with check ((customer_id = ( SELECT customer_profiles.id
   FROM customer_profiles
  WHERE (customer_profiles.user_id = auth.uid()))));


create policy "Customers can view their own favorite businesses"
on "public"."customer_favorite_businesses"
as permissive
for select
to authenticated
using ((customer_id = ( SELECT customer_profiles.id
   FROM customer_profiles
  WHERE (customer_profiles.user_id = auth.uid()))));


create policy "Users can delete their own favorite businesses"
on "public"."customer_favorite_businesses"
as permissive
for delete
to public
using ((auth.uid() = customer_id));


create policy "Users can insert their own favorite businesses"
on "public"."customer_favorite_businesses"
as permissive
for insert
to public
with check ((auth.uid() = customer_id));


create policy "Users can view their own favorite businesses"
on "public"."customer_favorite_businesses"
as permissive
for select
to public
using ((auth.uid() = customer_id));


create policy "Customers can manage their own favorite providers"
on "public"."customer_favorite_providers"
as permissive
for all
to authenticated
using ((customer_id = ( SELECT customer_profiles.id
   FROM customer_profiles
  WHERE (customer_profiles.user_id = auth.uid()))))
with check ((customer_id = ( SELECT customer_profiles.id
   FROM customer_profiles
  WHERE (customer_profiles.user_id = auth.uid()))));


create policy "Customers can view their own favorite providers"
on "public"."customer_favorite_providers"
as permissive
for select
to authenticated
using ((customer_id = ( SELECT customer_profiles.id
   FROM customer_profiles
  WHERE (customer_profiles.user_id = auth.uid()))));


create policy "Users can delete their own favorite providers"
on "public"."customer_favorite_providers"
as permissive
for delete
to public
using ((auth.uid() = customer_id));


create policy "Users can insert their own favorite providers"
on "public"."customer_favorite_providers"
as permissive
for insert
to public
with check ((auth.uid() = customer_id));


create policy "Users can view their own favorite providers"
on "public"."customer_favorite_providers"
as permissive
for select
to public
using ((auth.uid() = customer_id));


create policy "Allow anon read access"
on "public"."customer_locations"
as permissive
for select
to public
using (true);


create policy "read_own_locations"
on "public"."customer_locations"
as permissive
for select
to authenticated
using ((customer_id = auth.uid()));


create policy "Service role can access all profiles"
on "public"."customer_profiles"
as permissive
for all
to public
using (((auth.jwt() ->> 'role'::text) = 'service_role'::text));


create policy "Users can insert their own profile"
on "public"."customer_profiles"
as permissive
for insert
to public
with check ((auth.uid() = user_id));


create policy "Users can update their own profile"
on "public"."customer_profiles"
as permissive
for update
to public
using ((auth.uid() = user_id));


create policy "Users can view their own profile"
on "public"."customer_profiles"
as permissive
for select
to public
using ((auth.uid() = user_id));


create policy "Users can insert their own stripe profiles"
on "public"."customer_stripe_profiles"
as permissive
for insert
to public
with check ((auth.uid() = user_id));


create policy "Users can update their own stripe profiles"
on "public"."customer_stripe_profiles"
as permissive
for update
to public
using ((auth.uid() = user_id));


create policy "Users can view their own stripe profiles"
on "public"."customer_stripe_profiles"
as permissive
for select
to public
using ((auth.uid() = user_id));


create policy "Service role can manage email logs"
on "public"."email_logs"
as permissive
for all
to public
using ((auth.role() = 'service_role'::text));


create policy "Users can insert their own MFA challenges"
on "public"."mfa_challenges"
as permissive
for insert
to public
with check ((auth.uid() = user_id));


create policy "Users can update their own MFA challenges"
on "public"."mfa_challenges"
as permissive
for update
to public
using ((auth.uid() = user_id));


create policy "Users can view their own MFA challenges"
on "public"."mfa_challenges"
as permissive
for select
to public
using ((auth.uid() = user_id));


create policy "Users can delete their own MFA factors"
on "public"."mfa_factors"
as permissive
for delete
to public
using ((auth.uid() = user_id));


create policy "Users can insert their own MFA factors"
on "public"."mfa_factors"
as permissive
for insert
to public
with check ((auth.uid() = user_id));


create policy "Users can update their own MFA factors"
on "public"."mfa_factors"
as permissive
for update
to public
using ((auth.uid() = user_id));


create policy "Users can view their own MFA factors"
on "public"."mfa_factors"
as permissive
for select
to public
using ((auth.uid() = user_id));


create policy "Users can delete their own MFA sessions"
on "public"."mfa_sessions"
as permissive
for delete
to public
using ((auth.uid() = user_id));


create policy "Users can insert their own MFA sessions"
on "public"."mfa_sessions"
as permissive
for insert
to public
with check ((auth.uid() = user_id));


create policy "Users can view their own MFA sessions"
on "public"."mfa_sessions"
as permissive
for select
to public
using ((auth.uid() = user_id));


create policy "Users can insert their own MFA settings"
on "public"."mfa_settings"
as permissive
for insert
to public
with check ((auth.uid() = user_id));


create policy "Users can update their own MFA settings"
on "public"."mfa_settings"
as permissive
for update
to public
using ((auth.uid() = user_id));


create policy "Users can view their own MFA settings"
on "public"."mfa_settings"
as permissive
for select
to public
using ((auth.uid() = user_id));


create policy "Anyone can subscribe to newsletter"
on "public"."newsletter_subscribers"
as permissive
for insert
to anon
with check (true);


create policy "Service role can manage all newsletter subscribers"
on "public"."newsletter_subscribers"
as permissive
for all
to service_role
using (true)
with check (true);


create policy "Users can view their own notification logs"
on "public"."notification_logs"
as permissive
for select
to public
using ((auth.uid() = user_id));


create policy "platform_admins_summary_access"
on "public"."platform_annual_tax_summary"
as permissive
for all
to public
using ((EXISTS ( SELECT 1
   FROM auth.users
  WHERE ((users.id = auth.uid()) AND ((users.raw_user_meta_data ->> 'role'::text) = 'platform_admin'::text)))));


create policy "Allow anon delete access"
on "public"."promotion_usage"
as permissive
for delete
to public
using (true);


create policy "Allow anon insert access"
on "public"."promotion_usage"
as permissive
for insert
to public
with check (true);


create policy "Allow anon read access"
on "public"."promotion_usage"
as permissive
for select
to public
using (true);


create policy "Allow anon update access"
on "public"."promotion_usage"
as permissive
for update
to public
using (true);


create policy "Allow anon delete access"
on "public"."promotions"
as permissive
for delete
to public
using (true);


create policy "Allow anon insert access"
on "public"."promotions"
as permissive
for insert
to public
with check (true);


create policy "Allow anon read access"
on "public"."promotions"
as permissive
for select
to public
using (true);


create policy "Allow anon update access"
on "public"."promotions"
as permissive
for update
to public
using (true);


create policy "Allow anon read access"
on "public"."provider_addons"
as permissive
for select
to public
using (true);


create policy "Allow anon read access"
on "public"."provider_services"
as permissive
for select
to public
using (true);


create policy "Allow anon read access"
on "public"."providers"
as permissive
for select
to public
using (true);


create policy "Anyone can view active providers"
on "public"."providers"
as permissive
for select
to public
using (((is_active = true) AND (verification_status = 'documents_submitted'::provider_verification_status)));


create policy "Business owners can manage their providers"
on "public"."providers"
as permissive
for all
to public
using (((auth.jwt() ->> 'business_id'::text) = (business_id)::text));


create policy "Providers can update their own profile"
on "public"."providers"
as permissive
for update
to public
using ((auth.uid() = user_id));


create policy "Providers can view their own profile"
on "public"."providers"
as permissive
for select
to public
using ((auth.uid() = user_id));


create policy "Service role can access all providers"
on "public"."providers"
as permissive
for all
to public
using (((auth.jwt() ->> 'role'::text) = 'service_role'::text));


create policy "Allow admin update access"
on "public"."reviews"
as permissive
for update
to public
using (true);


create policy "Allow anon insert access"
on "public"."reviews"
as permissive
for insert
to public
with check (true);


create policy "Allow anon read access"
on "public"."reviews"
as permissive
for select
to public
using (true);


create policy "Allow anon read access"
on "public"."service_addon_eligibility"
as permissive
for select
to public
using (true);


create policy "Users can insert own stripe accounts"
on "public"."stripe_connect_accounts"
as permissive
for insert
to public
with check ((auth.uid() = user_id));


create policy "Users can update own stripe accounts"
on "public"."stripe_connect_accounts"
as permissive
for update
to public
using ((auth.uid() = user_id));


create policy "Users can view own stripe accounts"
on "public"."stripe_connect_accounts"
as permissive
for select
to public
using ((auth.uid() = user_id));


create policy "Users can insert own verifications"
on "public"."stripe_identity_verifications"
as permissive
for insert
to public
with check ((auth.uid() = user_id));


create policy "Users can update own verifications"
on "public"."stripe_identity_verifications"
as permissive
for update
to public
using ((auth.uid() = user_id));


create policy "Users can view own verifications"
on "public"."stripe_identity_verifications"
as permissive
for select
to public
using ((auth.uid() = user_id));


create policy "platform_admins_webhook_access"
on "public"."stripe_tax_webhook_events"
as permissive
for all
to public
using ((EXISTS ( SELECT 1
   FROM auth.users
  WHERE ((users.id = auth.uid()) AND ((users.raw_user_meta_data ->> 'role'::text) = 'platform_admin'::text)))));


create policy "Allow admin updates to system config"
on "public"."system_config"
as permissive
for all
to public
using ((((auth.jwt() ->> 'role'::text) = 'admin'::text) OR ((auth.jwt() ->> 'user_role'::text) = 'admin'::text)));


create policy "Allow anon delete access"
on "public"."system_config"
as permissive
for delete
to public
using (true);


create policy "Allow anon insert access"
on "public"."system_config"
as permissive
for insert
to public
with check (true);


create policy "Allow anon read access"
on "public"."system_config"
as permissive
for select
to public
using (true);


create policy "Allow anon update access"
on "public"."system_config"
as permissive
for update
to public
using (true);


create policy "Allow public read access to public system config"
on "public"."system_config"
as permissive
for select
to public
using ((is_public = true));


create policy "Allow reading system config"
on "public"."system_config"
as permissive
for select
to public
using (true);


create policy "Business owners can view tips for their business"
on "public"."tips"
as permissive
for select
to public
using (((auth.jwt() ->> 'business_id'::text) = (business_id)::text));


create policy "Customers can view their own tips"
on "public"."tips"
as permissive
for select
to public
using ((auth.uid() IN ( SELECT customer_profiles.user_id
   FROM customer_profiles
  WHERE (customer_profiles.id = tips.customer_id))));


create policy "Providers can view their tips"
on "public"."tips"
as permissive
for select
to public
using ((auth.uid() IN ( SELECT providers.user_id
   FROM providers
  WHERE (providers.id = tips.provider_id))));


create policy "Service role can access all tips"
on "public"."tips"
as permissive
for all
to public
using (((auth.jwt() ->> 'role'::text) = 'service_role'::text));


create policy "Admin users can manage all settings"
on "public"."user_settings"
as permissive
for all
to authenticated
using ((EXISTS ( SELECT 1
   FROM admin_users
  WHERE (admin_users.id = auth.uid()))));


create policy "Users can delete their own settings"
on "public"."user_settings"
as permissive
for delete
to public
using ((auth.uid() = user_id));


create policy "Users can insert their own settings"
on "public"."user_settings"
as permissive
for insert
to public
with check ((auth.uid() = user_id));


create policy "Users can update their own settings"
on "public"."user_settings"
as permissive
for update
to public
using ((auth.uid() = user_id))
with check ((auth.uid() = user_id));


create policy "Users can view their own settings"
on "public"."user_settings"
as permissive
for select
to public
using ((auth.uid() = user_id));


CREATE TRIGGER enforce_booking_location_rules BEFORE INSERT OR UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION validate_booking_location();

CREATE TRIGGER generate_booking_reference_trigger BEFORE INSERT ON public.bookings FOR EACH ROW WHEN ((new.booking_reference IS NULL)) EXECUTE FUNCTION generate_booking_reference();

CREATE TRIGGER track_business_payment_for_stripe_tax AFTER UPDATE ON public.bookings FOR EACH ROW EXECUTE FUNCTION track_business_payment_for_tax();

CREATE TRIGGER validate_business_addon_eligibility_trigger BEFORE INSERT OR UPDATE ON public.business_addons FOR EACH ROW EXECUTE FUNCTION validate_business_addon_eligibility();

CREATE TRIGGER update_business_annual_tax_tracking_updated_at BEFORE UPDATE ON public.business_annual_tax_tracking FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_manual_bank_accounts_updated_at BEFORE UPDATE ON public.business_manual_bank_accounts FOR EACH ROW EXECUTE FUNCTION update_manual_bank_accounts_updated_at();

CREATE TRIGGER update_business_service_categories_updated_at BEFORE UPDATE ON public.business_service_categories FOR EACH ROW EXECUTE FUNCTION update_business_service_categories_updated_at();

CREATE TRIGGER update_business_service_subcategories_updated_at BEFORE UPDATE ON public.business_service_subcategories FOR EACH ROW EXECUTE FUNCTION update_business_service_subcategories_updated_at();

CREATE TRIGGER enforce_minimum_price BEFORE INSERT OR UPDATE ON public.business_services FOR EACH ROW EXECUTE FUNCTION check_business_price_above_minimum();

CREATE TRIGGER trg_bsti_updated_at BEFORE UPDATE ON public.business_stripe_tax_info FOR EACH ROW EXECUTE FUNCTION set_bsti_updated_at();

CREATE TRIGGER update_business_stripe_tax_info_updated_at BEFORE UPDATE ON public.business_stripe_tax_info FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contact_submissions_updated_at BEFORE UPDATE ON public.contact_submissions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER handle_conversation_metadata_updated_at BEFORE UPDATE ON public.conversation_metadata FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE TRIGGER update_customer_stripe_profiles_updated_at BEFORE UPDATE ON public.customer_stripe_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_mfa_factors_updated_at BEFORE UPDATE ON public.mfa_factors FOR EACH ROW EXECUTE FUNCTION update_mfa_factors_updated_at();

CREATE TRIGGER trigger_update_mfa_settings_updated_at BEFORE UPDATE ON public.mfa_settings FOR EACH ROW EXECUTE FUNCTION update_mfa_settings_updated_at();

CREATE TRIGGER update_newsletter_subscribers_updated_at BEFORE UPDATE ON public.newsletter_subscribers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_platform_annual_tax_summary_updated_at BEFORE UPDATE ON public.platform_annual_tax_summary FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


