In addition to text, image, and video, the **Bluesky API** supports several other post types and embedded formats that developers can use to create richer interactions. Each post record is based on the `app.bsky.feed.post` schema, but can include **embeds**, **facets**, and **references** that extend its functionality beyond plain media posts.  

### Supported Post Types

| Type | Description |
|------|--------------|
| Text post | Basic text-only messages up to **300 characters**, with multilingual `langs` support using BCP-47 tags and metadata for timestamps[2]. |
| Image post | Posts with up to **4 images per post**, embedded via `app.bsky.embed.images`, supporting JPEG, PNG, GIF, or WEBP formats[8][5]. |
| Video post | One video per post (MP4, MOV, WEBM), up to **3 minutes** and around **50–100 MB** in size, embedded via `app.bsky.embed.video`[8][11]. |
| Link post | Posts embedding rich web previews via `app.bsky.embed.external`, which generate titles, thumbnails, and descriptions for URLs[4][5]. |
| Quote post | A hybrid post that references and comments on another post using `app.bsky.embed.record` (similar to a quote-tweet), available since mid‑2025[8]. |
| Threaded replies | Posts linked via the `reply` field, referencing a parent and root post to form threads or conversations[1][5]. |
| Rich text posts | Posts containing **mentions, hashtags, and hyperlinks** using the `facets` attribute in JSON — supporting marked text elements like `@handles` and `https://links`[4]. |
| Reposts | Non-original posts created by making an `app.bsky.feed.repost` record referencing the target post’s URI[8]. |
| Alt text & accessibility | Media (image/video) embeds can include **alt descriptions**, captions, and optional subtitle files (`.vtt`)[12][8]. |

### Experimental or Planned Types
Ongoing protocol development aims to add:
- **Quote cards** and **polls**, using composite record types within `app.bsky.embed.composite` schemas.
- **Audio posts**, which are currently in testing under the `app.bsky.embed.audio` lexicon.[3]
- **Carousel embeds**, allowing multiple external or mixed media types, under evaluation for early 2026.[3]

In short, while standard Bluesky posts include text, image, and video, the API also supports rich embed types (links, quotes, reposts, threads, mentions) and emerging media types that expand expressiveness within the AT Protocol ecosystem.

[1](https://docs.bsky.app/docs/advanced-guides/posts)
[2](https://docs.bsky.app/blog/create-post)
[3](https://docs.bsky.app/blog/2025-protocol-roadmap-spring)
[4](https://docs.bsky.app/docs/advanced-guides/post-richtext)
[5](https://www.ayrshare.com/complete-guide-to-bluesky-api-integration-authorization-posting-analytics-comments/)
[6](https://publer.com/help/en/article/what-post-types-are-supported-and-what-are-their-limitations-1687rte/)
[7](https://onlysocial.io/bluesky-content-guidelines/)
[8](https://www.sprinklr.com/help/articles/bluesky/publish-a-post-using-bluesky/671b8e772e64c74e572386fa)
[9](https://help.hootsuite.com/hc/en-us/articles/41385442553755-Create-a-Bluesky-post)
[10](https://www.distribution.ai/blog/best-time-to-post-on-bluesky)
[11](https://dlvrit.com/blog/bluesky-video/)
[12](https://www.kapwing.com/resources/how-to-post-videos-on-bluesky/)