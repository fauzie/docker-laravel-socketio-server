# Laravel Echo Server Docker Image

Ready to use [Laravel Echo Server](https://github.com/tlaverdure/laravel-echo-server) as Docker image. Just pull, add config and run.

### Environment Configurations

| ENV              | Default    | Description                                                          |
| ---------------- | ---------- | -------------------------------------------------------------------- |
| `CLIENT_APP_ID`  | random(16) | The authenticated with an API ID                                     |
| `CLIENT_APP_KEY` | random(32) | The authenticated with an API KEY                                    |
| `DATABASE`       | `sqlite`   | Database used to store data that should persist. `redis` or `sqlite` |

You can also use laravel echo server dotenv configuration for initial setup.
Just map your env file as volume to /app/.env. See: `app/.env.example`

```bash
-v /home/username/.env:/app/.env
```

### Usage

[**Read More Here**](https://github.com/tlaverdure/laravel-echo-server)

---

Crafted by [fauzie](https://github.com/fauzie) with :heart: and :coffee:
