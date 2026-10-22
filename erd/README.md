# 현재 엔티티 ERD

기준: 백엔드의 도메인 엔티티 8개와 Flyway V1~V10·V12. 실제 데이터·사진·인증키는 포함하지 않습니다.

| 자료 | 용도 |
| --- | --- |
| [erdcloud-import.sql](erdcloud-import.sql) | ERDCloud의 Import에 SQL 전체를 붙여넣어 테이블·PK·UK·FK 생성 |
| [erd.mmd](erd.mmd) | 현재 테이블과 관계의 Mermaid 원본 |
| erd_261016_v1.png | 과거 ERD 이미지. 현재 구조는 위 두 파일 기준 |

## 테이블과 관계

- `members` → `posts`: 회원 한 명이 게시글 0개 이상 작성
- `members` → `comments`: 회원 한 명이 댓글 0개 이상 작성
- `posts` → `comments`: 게시글 하나에 댓글 0개 이상
- `members` → `member_favorites`: 회원별 관심 등록
- `missing_persons` → `member_favorites`: 실종아동별 관심 등록
- `missing_persons` → `missing_person_images`: 실종아동 한 명에 원본 사진 0장 이상
- `missing_persons` → `missing_person_ai_images`: 실종아동 한 명에 AI 결과 0장 이상
- `missing_person_images` → `missing_person_ai_images`: 원본 사진 한 장으로 AI 결과 여러 개 생성 가능
- `members` → `news_articles`: 관리자 한 명이 뉴스 기사 0개 이상 승인. 승인한 기사만 저장하며 노출 중단은 소프트 삭제

사진 테이블의 `missing_person_id`는 `missing_persons.id`를 참조합니다. 대표 사진 하나를 아동 테이블에 넣는 대신 사진마다 UUID를 부여하고 원본 BYTEA·순번·출처·형식·크기·해시를 보관합니다. `photo_url`은 기존 대표 사진 출처로 남아 있지만 화면에서는 별도 사진 조회 API를 사용합니다.

관심 등록은 `(member_id, missing_person_id)`, 사진은 `(missing_person_id, sort_order)` 조합이 UNIQUE입니다. 모든 도메인 테이블은 BaseEntity의 생성·수정·소프트 삭제 시각을 포함합니다. `deleted_at`이 NULL이면 소프트 삭제되지 않은 상태입니다. 사진 외래키의 `ON DELETE CASCADE`는 아동 행을 실제 DELETE할 때만 동작하고 소프트 삭제에는 동작하지 않습니다.

Import SQL은 그림 작성용입니다. 스키마 접두사·CHECK 제약·보조 인덱스는 생략했고 실제 DB에는 적용하지 않습니다. 실제 변경은 백엔드 Flyway SQL을 사용합니다. 사진에는 JPEG/PNG 형식, 최대 2MB, 바이트 수 일치, 64자리 소문자 해시, 0 이상 순번의 CHECK가 실제 DB에 추가되어 있습니다.

Spring Batch 실행 이력, Flyway 이력, 더미 데이터 생성 기록은 도메인 엔티티가 아닌 운영용 테이블이므로 이 ERD에서는 제외합니다. 로그인 세션은 Redis에서 관리합니다.

## ERDCloud에서 관계선이 빠지는 경우

실제 PostgreSQL에는 외래키 8개가 존재합니다. 화면의 관계선이 없는 것만으로 DB 외래키가 없다고 판단하지 않습니다. Import SQL은 모든 CREATE TABLE을 먼저, 외래키 ALTER TABLE을 마지막에 배치했습니다. 테이블 생성문만 복사하지 말고 파일 끝의 외래키 8개 선언까지 전체를 Import하세요.

기존 도식에 재Import가 반영되지 않으면 기존 도식을 보존한 상태에서 새 작업용 ERD에 전체 SQL을 Import하여 비교합니다. ERDCloud Import 결과 자체의 호환성은 실제 화면에서 확인해야 합니다. 현재 파일의 PostgreSQL 실행 및 외래키 정의 검증과는 별개입니다.

확인할 관계는 회원→게시글, 회원→댓글, 게시글→댓글, 회원→관심등록, 실종아동→관심등록, 실종아동→원본 사진, 실종아동→AI 결과, 원본 사진→AI 결과의 총 8개입니다.

## 대표 사진 및 AI 결과

원본·AI 테이블 각각 `is_main`을 사용하며 활성 대표는 아동별 최대 한 장입니다. 실제 DB의 부분 UNIQUE 인덱스가 중복 대표를 차단합니다. 기존 원본은 첫 활성 순번으로 초기화하고, AI는 최초 저장 결과를 기본 대표로 선택합니다. 이후 명시적 대표 선택을 유지합니다.

AI 테이블의 `content`는 생성 결과입니다. 경찰청 입력 사진은 `source_image_id`로 참조하며 복제하지 않습니다. 같은 아동의 원본만 연결하도록 `(source_image_id, missing_person_id)` → 원본 `(id, missing_person_id)` 복합 FK를 사용합니다. 원본의 `(id, missing_person_id)` UNIQUE는 이 참조를 위한 제약입니다.

ERDCloud에서 관계를 수동 연결할 때 기존 `member_id`, `missing_person_id`, `source_image_id`를 재사용해야 합니다. `id2`, `id3` 같은 새 컬럼이 생성되면 실제 DB와 다른 도식이 됩니다.
