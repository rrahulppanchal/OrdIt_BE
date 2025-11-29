FROM node:20-alpine AS builder

# Install pnpm and openssl
RUN apk add --no-cache openssl
RUN npm install -g pnpm

WORKDIR /app

COPY package.json pnpm-lock.yaml ./
COPY prisma ./prisma/

RUN pnpm install --frozen-lockfile

COPY . .

RUN pnpm run prisma:generate
RUN pnpm run build

FROM node:20-alpine

WORKDIR /app

# Install pnpm and openssl
RUN apk add --no-cache openssl
RUN npm install -g pnpm

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

EXPOSE 8000

CMD [ "sh", "-c", "pnpm run prisma:migrate:deploy && pnpm run start:prod" ]
