import { Hono } from "hono";
import { getAllUsers, getAllUrls, getAllUserUrls, shortenUrl, redirectUrl, isUrlAvailable, checkViews } from "./service";

const routes = new Hono();

// routes.get("/users", getAllUsers);
// routes.get("/urls", getAllUrls);
// routes.get("/user-urls", getAllUserUrls);
routes.post("/shorten", shortenUrl);
routes.get("/:shortCode", redirectUrl);
routes.get("/is-available/:url", isUrlAvailable);
routes.get("/views/:url", checkViews);

export { routes };
