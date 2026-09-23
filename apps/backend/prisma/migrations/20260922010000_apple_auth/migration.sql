ALTER TABLE "users" ADD COLUMN "apple_id" TEXT, ADD COLUMN "apple_refresh_token" TEXT;
CREATE UNIQUE INDEX "users_apple_id_key" ON "users"("apple_id");
