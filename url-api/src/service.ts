import { Context } from "hono";

import isUrlHttp from 'is-url-http';

import { getDbClient } from "./db";
import { TABLE_USER, TABLE_URL, TABLE_USER_URL } from "./db";
import { UNSUPPORTED_URLS } from "./constants";

export async function getAllUsers(c: Context) {
    try {
        const client = getDbClient(c);
        const { rows } = await client.query(`SELECT * FROM ${TABLE_USER}`);
        return c.json(rows);
    } catch (error) {
        console.error("Error getting users:", error);
        return c.text("Error getting users", 500);
    }
}

export async function getAllUrls(c: Context) {
    try {
        const client = getDbClient(c);
        const { rows } = await client.query(`SELECT * FROM ${TABLE_URL}`);
        return c.json(rows);
    } catch (error) {
        console.error("Error getting urls:", error);
        return c.text("Error getting urls", 500);
    }
}

export async function getAllUserUrls(c: Context) {
    try {
        const client = getDbClient(c);
        const { rows } = await client.query(`SELECT * FROM ${TABLE_USER_URL}`);
        return c.json(rows);
    } catch (error) {
        console.error("Error getting user_urls:", error);
        return c.text("Error getting user_urls", 500);
    }
}

export async function shortenUrl(c: Context) {
    try {
        var { url, shortCode } = await c.req.json();
        console.log("shortCode-r", shortCode);
        console.log("url-r", url);

        if (!url) return c.json({ "error": "invalid request" }, 400);

        if (!url.startsWith("http")) url = "https://" + url;
        if (!isUrlHttp(url)) return c.json({ "error": "invalid url" }, 400);

        if (isNotSupported(url)) return c.json({ "error": "url is not supported" }, 400);
        
        if (shortCode) {
            console.log("shortCode:", shortCode);
            if (shortCode.length < 3 || shortCode.length > 50) return c.json({ "error": "short code length must be between 3 and 50 characters" }, 400);
            if (await isShortCodeTaken(c, shortCode)) return c.json({ "error": "url is already taken" }, 400);
        }
        if (!shortCode || shortCode.length < 1) shortCode = await getUniqueShortUrl(c);
        
        const result = await saveUrlToDbshortCode(c, url, shortCode);
        return c.json({ shortCode, url }, 201);
    } catch (error) {
        console.error("Error shortening URL:", error);
        return c.text("Error shortening URL", 500);
    }
}

export async function redirectUrl(c: Context) {
    try {
        const shortCode = c.req.param("shortCode");
        console.log('shortCode', shortCode);

        const client = getDbClient(c);
        const result = await client.query(`SELECT * FROM ${TABLE_URL} WHERE short_code = $1`, [
            shortCode,
        ]);
        if (result.rows.length === 0) {
            return c.text("Not Found", 404);
        }
        const originalUrl = result.rows[0].original_url;
        await client.query(`UPDATE ${TABLE_URL} SET clicks = clicks + 1 WHERE short_code = $1`, [
            shortCode,
        ]);
        return c.redirect(originalUrl, 301);
    } catch (error) {
        console.error("Error redirecting URL:", error);
        return c.text("Error redirecting URL", 500);
    }
}

export async function zara(c: Context) {
    try {
        const shortCode = c.req.param("shortCode");
        console.log('shortCode', shortCode);

        const client = getDbClient(c);
        const result = await client.query(`SELECT * FROM ${TABLE_URL} WHERE short_code = $1`, [
            shortCode,
        ]);
        if (result.rows.length === 0) {
            return c.text("Not Found", 404);
        }
        const originalUrl = result.rows[0].original_url;
        await client.query(`UPDATE ${TABLE_URL} SET clicks = clicks + 1 WHERE short_code = $1`, [
            shortCode,
        ]);
        return c.redirect(originalUrl, 302);
    } catch (error) {
        console.error("Error redirecting URL:", error);
        return c.text("Error redirecting URL", 500);
    }
}

export async function isUrlAvailable(c: Context) {
    var isTaken: boolean = false;
    try {
        const url = c.req.param("url");
        if (!url) {
            isTaken = true;
            return c.json({ isTaken });
        }
        console.log("int try", url);
        console.log(url);

        console.log("in try b4", isTaken);
        isTaken = await isShortCodeTaken(c, url);
        console.log("in try aftr", isTaken);
    } catch (error) {
        console.log("out try", error);
    }
    return c.json({ isAvailable: !isTaken });
}

export async function checkViews(c: Context) {
    try {
        const url = c.req.param("url");
        if (url.length < 3) return c.json({ error: "invalid request" }, 400);
        const views = await getByShortcode(c, url);
        if (views.rows.length === 0) return c.json({ error: "not found" }, 404);
        return c.json({ views: views.rows[0].clicks }, 200);
    } catch (error) {
        return c.json({ "error": "invalid request" }, 500);
    }
}

function generateShortUrl(): string {
    // Basic short code generator (you should use a more robust method in production)
    const characters = "ABCDEFGHJKMNOPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz0123456789"; //  L, l & I removed
    let shortCode = "";
    for (let i = 0; i < 6; i++) {
        shortCode += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return shortCode;
}

async function saveUrlToDbshortCode(c: Context, url: string, shortCode: string, userId: string = "") {
    const client = getDbClient(c);
    var result;
    if (!userId) {
        let result = await client.query(
            `INSERT INTO ${TABLE_URL} (original_url, short_code) VALUES ($1, $2) RETURNING *`,
            [url, shortCode],
        );
        result = result.rows[0];
    }

    if (userId) {
        const result = await client.query(
            `INSERT INTO ${TABLE_USER_URL} (user_id, original_url, short_code) VALUES ($1, $2, $3) RETURNING *`,
            [userId, url, shortCode],
        );
        return result.rows[0];
    }

}

async function isShortCodeTaken(c: Context, shortCode: string) {
    const client = getDbClient(c);
    let isTaken = await client.query(
        `SELECT * FROM ${TABLE_URL} WHERE short_code = $1`,
        [shortCode],
    );
    return isTaken.rows.length > 0;
}

async function getByShortcode(c: Context, shortCode: string) {
    const client = getDbClient(c);
    let views = await client.query(
        `SELECT clicks FROM ${TABLE_URL} WHERE short_code = $1`,
        [shortCode],
    );
    return views;
}

async function getUniqueShortUrl(c: Context) {
    let shortCode = generateShortUrl();
    while (await isShortCodeTaken(c, shortCode)) {
        shortCode = generateShortUrl();
    }
    return shortCode;
}

function isNotSupported(url: string): boolean {
    return UNSUPPORTED_URLS.some(unsupported => url.includes(unsupported));
}

