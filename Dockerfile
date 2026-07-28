# syntax=docker/dockerfile:1

FROM mcr.microsoft.com/dotnet/aspnet:9.0-bookworm-slim AS runtime

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && rm -rf /var/lib/apt/lists/* \
    && if ! getent group app >/dev/null; then groupadd --system app; fi \
    && if ! id -u app >/dev/null 2>&1; then useradd --system --gid app --create-home app; fi \
    && mkdir -p /home/app/.aspnet/DataProtection-Keys \
    && chown -R app:app /home/app/.aspnet /app

ENV ASPNETCORE_ENVIRONMENT=Production \
    ASPNETCORE_URLS=http://+:8080 \
    DOTNET_RUNNING_IN_CONTAINER=true

EXPOSE 8080

COPY --chown=app:app . ./

USER app

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD curl --fail --silent --show-error -H "X-Forwarded-Proto: https" http://127.0.0.1:8080/health || exit 1

ENTRYPOINT ["dotnet", "Project.dll"]
