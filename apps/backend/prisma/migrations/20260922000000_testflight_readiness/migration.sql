ALTER TABLE "users" ADD COLUMN "session_version" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN "password_reset_hash" TEXT,
ADD COLUMN "password_reset_expires_at" TIMESTAMP(3),
ADD COLUMN "password_reset_requested_at" TIMESTAMP(3);
ALTER TABLE "settings" ADD COLUMN "ai_consent_version" TEXT,
ADD COLUMN "ai_consent_provider" TEXT,
ADD COLUMN "ai_consent_at" TIMESTAMP(3);
