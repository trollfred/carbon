FROM elixir:1.11 AS build

WORKDIR /carbon

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

COPY lib lib
RUN mix do compile, release

FROM buildpack-deps:buster AS carbon

WORKDIR /carbon

COPY --from=build /carbon/_build/prod/rel/carbon ./

ENV HOME=/carbon

CMD ["bin/carbon", "start"]
