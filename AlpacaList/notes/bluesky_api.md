The Bluesky / AT Protocol feed-related APIs allow posting, retrieving, and interacting with feed content through defined lexicons under the namespace `app.bsky.feed.*`. These endpoints are usually accessed via a user’s **Personal Data Server (PDS)** or a public **AppView API** (`https://public.api.bsky.app`).  

### Feed Posting

**Endpoint:**  
`POST /xrpc/com.atproto.repo.createRecord` with `collection` set to `"app.bsky.feed.post"`  
**Purpose:**  
Creates a feed post in the user’s repository.  
**Payload Example:**  
```json
{
  "repo": "did:example:user",
  "collection": "app.bsky.feed.post",
  "record": {
    "text": "Hello Bluesky!",
    "createdAt": "2025-10-22T22:00:00Z"
  }
}
```
This defines a post record according to the `app.bsky.feed.post` schema.[1]

### Feed Retrieval

| Function | Endpoint | Description |
|-----------|-----------|-------------|
| Get Timeline | `/xrpc/app.bsky.feed.getTimeline` | Returns a user’s home timeline (reverse-chronological list of followed users’ posts)[2][3]. |
| Get Author Feed | `/xrpc/app.bsky.feed.getAuthorFeed` | Returns all posts from a specific user’s account (author feed)[3]. |
| Get Feed Generator | `/xrpc/app.bsky.feed.getFeedGenerator` | Fetches metadata describing a custom feed generator (name, creator, description, etc.)[4]. |
| Get Feed | `/xrpc/app.bsky.feed.getFeed` | Retrieves a specific feed from a generator (by URI)[5][3]. |
| Get Posts | `/xrpc/app.bsky.feed.getPosts` | Returns post views for a list of post URIs (“hydrating” skeleton posts)[6]. |
| Get Post Thread | `/xrpc/app.bsky.feed.getPostThread` | Fetches a full thread of replies to a given post[7]. |
| Search Posts | `/xrpc/app.bsky.feed.searchPosts` | Searches posts across the network by keywords, hashtags, etc.[8]. |
| Describe Feed Generator | `/xrpc/app.bsky.feed.describeFeedGenerator` | Returns configuration, feed URIs, and implementation policies for a given feed generator service[9]. |

### Feed Interactions

Although likes, reposts, and replies are separate record types, they connect to feed posts through standard AT record references:
- **Like post** – create a record in `app.bsky.feed.like` referencing the target post URI.  
- **Repost (reshare)** – create a record in `app.bsky.feed.repost`.  
- **Reply** – create a new `app.bsky.feed.post` including a `reply` field pointing to the parent post and root thread.  
- **Send bulk interactions** – supported by `/xrpc/app.bsky.feed.sendInteractions`, typically for batch liking or reposting within clients.[10]

### Example Workflow

1. **Post:** `com.atproto.repo.createRecord` (collection = `app.bsky.feed.post`)  
2. **Fetch:** `app.bsky.feed.getTimeline` or `app.bsky.feed.getAuthorFeed`  
3. **Interact:** `app.bsky.feed.like`, `app.bsky.feed.repost`, or thread replies  

Each HTTP call uses standard **Bearer authentication**, and endpoints accept pagination parameters like `cursor` and `limit` for navigating large feeds.[2][3]

In summary, the feed-related XRPC endpoints under `app.bsky.feed.*` define the lifecycle of post creation, retrieval, and interaction across Bluesky’s federated social layer.

[1](https://docs.bsky.app/blog/create-post)
[2](https://docs.bsky.app/docs/api/app-bsky-feed-get-timeline)
[3](https://docs.bsky.app/docs/tutorials/viewing-feeds)
[4](https://docs.bsky.app/docs/tutorials/custom-feeds)
[5](https://docs.bsky.app/docs/api/app-bsky-feed-get-feed)
[6](https://docs.bsky.app/docs/api/app-bsky-feed-get-posts)
[7](https://docs.bsky.app/docs/api/app-bsky-feed-get-post-thread)
[8](https://docs.bsky.app/docs/api/app-bsky-feed-search-posts)
[9](https://docs.bsky.app/docs/api/app-bsky-feed-describe-feed-generator)
[10](https://docs.bsky.app/docs/category/http-reference)