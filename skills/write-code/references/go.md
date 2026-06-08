# Go Code Reference

Use this reference for Go code changes.

## Construction

Use `New...` constructor functions for behavior objects that hold dependencies, need validation, or may need setup later.

Good candidates:

```go
repo := user.NewRepository(db)
service := user.NewService(repo, cache, queue)
handler := user.NewHandler(service)
consumer := user.NewSendWelcomeEmailConsumer(emailSender, logger)
worker := queue.NewWorker(redisQueue)
```

Reasoning:

- dependencies can stay in unexported fields
- constructors can validate required dependencies
- constructors can apply defaults
- call sites do not depend on internal field names

Example:

```go
type SendWelcomeEmailConsumer struct {
	emailSender EmailSender
	logger      *slog.Logger
}

func NewSendWelcomeEmailConsumer(
	emailSender EmailSender,
	logger *slog.Logger,
) *SendWelcomeEmailConsumer {
	if emailSender == nil {
		panic("emailSender is required")
	}

	if logger == nil {
		logger = slog.Default()
	}

	return &SendWelcomeEmailConsumer{
		emailSender: emailSender,
		logger:      logger,
	}
}
```

Use direct struct literals for simple data.

```go
job := user.SendWelcomeEmailJob{
	UserID: user.ID.Hex(),
	Email:  user.Email,
	Name:   user.Name,
}
```

Do not add `New...` constructors for plain DTOs or job payloads unless construction has validation, defaults, or normalization that must always happen.

## Queue Jobs

Use job-oriented names for background work. Do not use `Event` unless the project is explicitly modeling domain events or event-driven architecture.

Recommended shape:

```go
type SendWelcomeEmailJob struct {
	UserID string `json:"user_id"`
	Email  string `json:"email"`
	Name   string `json:"name"`
}

func (SendWelcomeEmailJob) Type() string {
	return "user.send_welcome_email"
}
```

Keep the queue routing type in a generic infrastructure envelope:

```go
type Job struct {
	Type string          `json:"type"`
	Body json.RawMessage `json:"body"`
}
```

Use `Publish` as the application-facing helper and `Enqueue` as the lower-level adapter method.

```go
type TypedJob interface {
	Type() string
}

type Publisher interface {
	Enqueue(ctx context.Context, job Job) error
}

func Publish(ctx context.Context, publisher Publisher, payload TypedJob) error {
	body, err := json.Marshal(payload)
	if err != nil {
		return err
	}

	return publisher.Enqueue(ctx, Job{
		Type: payload.Type(),
		Body: body,
	})
}
```

Feature code should publish concrete jobs:

```go
return queue.Publish(ctx, s.queue, user.SendWelcomeEmailJob{
	UserID: user.ID.Hex(),
	Email:  user.Email,
	Name:   user.Name,
})
```

Workers can route by the concrete job's `Type()`:

```go
worker.Handle(
	user.SendWelcomeEmailJob{}.Type(),
	sendWelcomeEmailConsumer.Handle,
)
```

This keeps the business-level type simple while queued JSON remains explicit:

```json
{
  "type": "user.send_welcome_email",
  "body": {
    "user_id": "123",
    "email": "ana@example.com",
    "name": "Ana"
  }
}
```

## Package Boundaries

Keep infrastructure adapters generic and business-unaware.

- Feature packages own business models, request DTOs, services, repositories, jobs, and handlers.
- Platform packages own technology adapters such as Mongo, Redis, SQS, cache, queue, and HTTP helpers.
- Services depend on narrow interfaces for cache, queue, and other external capabilities.
- Repositories hide Mongo queries from services.

## Naming

Prefer short names that describe the role:

- `NewService`, `NewRepository`, `NewHandler`, `NewWorker`
- `SendWelcomeEmailJob`
- `SendWelcomeEmailConsumer`
- `HandleSendWelcomeEmail`
- `Enqueue` for queue adapter methods
- `Publish` for helper functions that wrap concrete jobs

Avoid confusing pairs such as:

```go
EventUserCreated
UserCreatedEvent
```

Those names hide whether the value is a routing key, a payload, or a domain event.

## Verification

After Go edits, prefer:

```bash
gofmt -w <changed-go-files>
go test ./...
```

For narrow changes, run the smallest package test first, then broaden if shared packages changed.
