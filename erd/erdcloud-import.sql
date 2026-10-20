-- ERDCloud Import용입니다. 실제 DB에 실행하지 않습니다.
-- 도메인 엔티티 7개를 모두 생성한 다음 외래키 8개를 마지막에 선언합니다.
-- findus 스키마 접두사와 CHECK·보조 인덱스는 도식화를 위해 생략했습니다.
-- TIMESTAMP(6)는 실제 DB의 WITHOUT TIME ZONE 타입이며 UTC 기준입니다.

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

-- 실종아동 - photo_url은 기존 대표 사진 출처
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

-- 관심아동 - 회원·실종아동 조합 UNIQUE
CREATE TABLE member_favorites (
    id UUID NOT NULL,
    member_id UUID NOT NULL,
    missing_person_id UUID NOT NULL,
    created_at TIMESTAMP(6) NOT NULL,
    updated_at TIMESTAMP(6) NOT NULL,
    deleted_at TIMESTAMP(6) NULL,
    CONSTRAINT pk_member_favorites PRIMARY KEY (id),
    CONSTRAINT uk_member_favorites_member_missing UNIQUE (member_id, missing_person_id)
);

-- 실종아동 사진 - 사진 원본 BYTEA 및 아동·순번 조합 UNIQUE
CREATE TABLE missing_person_images (
    id UUID NOT NULL,
    missing_person_id UUID NOT NULL,
    sort_order INTEGER NOT NULL,
    source_url VARCHAR(1024) NOT NULL,
    content_type VARCHAR(30) NOT NULL,
    content BYTEA NOT NULL,
    byte_size INTEGER NOT NULL,
    sha256 VARCHAR(64) NOT NULL,
    is_main BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP(6) NOT NULL,
    updated_at TIMESTAMP(6) NOT NULL,
    deleted_at TIMESTAMP(6) NULL,
    CONSTRAINT pk_missing_person_images PRIMARY KEY (id),
    CONSTRAINT uk_missing_images_person_order UNIQUE (missing_person_id, sort_order),
    CONSTRAINT uk_missing_images_id_person UNIQUE (id, missing_person_id)
);

-- AI 생성 결과: 원본은 FK로 참조하고 생성 결과 파일만 저장합니다.
CREATE TABLE missing_person_ai_images (
    id UUID NOT NULL,
    missing_person_id UUID NOT NULL,
    source_image_id UUID NOT NULL,
    target_age INTEGER NOT NULL,
    content BYTEA NOT NULL,
    content_type VARCHAR(30) NOT NULL,
    byte_size INTEGER NOT NULL,
    is_main BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP(6) NOT NULL,
    updated_at TIMESTAMP(6) NOT NULL,
    deleted_at TIMESTAMP(6) NULL,
    CONSTRAINT pk_missing_person_ai_images PRIMARY KEY (id)
);

-- 모든 CREATE TABLE 이후에 관계를 선언합니다. 아래 8개 구문까지 전체를 Import하세요.

ALTER TABLE posts
    ADD CONSTRAINT fk_posts_member
    FOREIGN KEY (member_id) REFERENCES members (id);

ALTER TABLE comments
    ADD CONSTRAINT fk_comments_post
    FOREIGN KEY (post_id) REFERENCES posts (id);

ALTER TABLE comments
    ADD CONSTRAINT fk_comments_member
    FOREIGN KEY (member_id) REFERENCES members (id);

ALTER TABLE member_favorites
    ADD CONSTRAINT fk_member_favorites_member
    FOREIGN KEY (member_id) REFERENCES members (id);

ALTER TABLE member_favorites
    ADD CONSTRAINT fk_member_favorites_missing
    FOREIGN KEY (missing_person_id) REFERENCES missing_persons (id);

ALTER TABLE missing_person_images
    ADD CONSTRAINT fk_missing_images_person
    FOREIGN KEY (missing_person_id) REFERENCES missing_persons (id) ON DELETE CASCADE;

ALTER TABLE missing_person_ai_images
    ADD CONSTRAINT fk_ai_images_person
    FOREIGN KEY (missing_person_id) REFERENCES missing_persons (id) ON DELETE CASCADE;

-- 두 컬럼을 같이 참조하여 다른 아동의 원본 연결을 차단합니다.
ALTER TABLE missing_person_ai_images
    ADD CONSTRAINT fk_ai_images_source_person
    FOREIGN KEY (source_image_id, missing_person_id)
    REFERENCES missing_person_images (id, missing_person_id);
