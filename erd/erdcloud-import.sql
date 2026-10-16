-- ERDCloud Import용입니다. 엔티티 4개의 컬럼·기본키·유니크 키·외래키를 포함합니다.
-- findus 스키마 접두사와 CHECK·인덱스는 도식화를 위해 생략했습니다.
-- TIMESTAMP(6)는 PostgreSQL의 WITHOUT TIME ZONE 타입이며 UTC 기준으로 사용합니다.

-- 회원
CREATE TABLE members (
    id UUID NOT NULL,
    email VARCHAR(254) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    nickname VARCHAR(50) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'USER',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP(6) NOT NULL,
    updated_at TIMESTAMP(6) NOT NULL,
    deleted_at TIMESTAMP(6) NULL,
    CONSTRAINT pk_members PRIMARY KEY (id),
    CONSTRAINT uk_members_email UNIQUE (email)
);

-- 게시글
CREATE TABLE posts (
    id UUID NOT NULL,
    member_id UUID NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP(6) NOT NULL,
    updated_at TIMESTAMP(6) NOT NULL,
    deleted_at TIMESTAMP(6) NULL,
    CONSTRAINT pk_posts PRIMARY KEY (id)
);

-- 댓글
CREATE TABLE comments (
    id UUID NOT NULL,
    post_id UUID NOT NULL,
    member_id UUID NOT NULL,
    content VARCHAR(1000) NOT NULL,
    created_at TIMESTAMP(6) NOT NULL,
    updated_at TIMESTAMP(6) NOT NULL,
    deleted_at TIMESTAMP(6) NULL,
    CONSTRAINT pk_comments PRIMARY KEY (id)
);

-- 안전Dream 실종자
CREATE TABLE missing_persons (
    id UUID NOT NULL,
    source_id VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(3) NOT NULL,
    sex TEXT NULL,
    occurrence_date TEXT NULL,
    age INTEGER NULL,
    age_now INTEGER NULL,
    address TEXT NULL,
    clothing TEXT NULL,
    features TEXT NULL,
    photo_url VARCHAR(500) NULL,
    source_available BOOLEAN NOT NULL DEFAULT TRUE,
    last_seen_at TIMESTAMP(6) NOT NULL,
    created_at TIMESTAMP(6) NOT NULL,
    updated_at TIMESTAMP(6) NOT NULL,
    deleted_at TIMESTAMP(6) NULL,
    CONSTRAINT pk_missing_persons PRIMARY KEY (id),
    CONSTRAINT uk_missing_persons_source UNIQUE (source_id)
);

-- 회원 한 명은 게시글 여러 개를 작성할 수 있습니다.
ALTER TABLE posts
    ADD CONSTRAINT fk_posts_member
    FOREIGN KEY (member_id) REFERENCES members (id);

-- 게시글 하나에는 댓글 여러 개가 달릴 수 있습니다.
ALTER TABLE comments
    ADD CONSTRAINT fk_comments_post
    FOREIGN KEY (post_id) REFERENCES posts (id);

-- 회원 한 명은 댓글 여러 개를 작성할 수 있습니다.
ALTER TABLE comments
    ADD CONSTRAINT fk_comments_member
    FOREIGN KEY (member_id) REFERENCES members (id);
