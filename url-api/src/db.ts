import { Client } from "@neondatabase/serverless";
import { Context, Next } from "hono";

export const TABLE_URL = "url";
export const TABLE_USER = '"user"';
export const TABLE_USER_URL = "user_url";

export const handleDbConnection = async (c: Context, next: Next) => {
    const client = new Client(c.env.DATABASE_URL);
    try {
        await client.connect();
        c.set("client", client);
        await next();
    } catch (error) {
        console.error("Database connection failed:", error);
        return c.text("Database connection error", 500);
    } finally {
        await c.get("client").end();
    }
};

export const getDbClient = (c: Context) => {
    return c.get("client");
};
