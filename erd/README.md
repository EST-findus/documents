# 테이블 명세서 — ERD v3

기준: 백엔드 Flyway V1~V10, `findus` 스키마의 도메인 테이블 7개. `TIMESTAMP(6)`는 시간대 없는 타입이며 UTC 기준으로 저장합니다.

## members — 회원

| 컬럼 | 타입 | NULL 허용 | 키·기본값 | 설명 |
| --- | --- | --- | --- | --- |
| `id` | `UUID` | 아니요 | PK | 회원 UUID. JPA에서 생성 |
| `email` | `VARCHAR(254)` | 아니요 | UNIQUE | 공백 제거·소문자 정규화한 로그인 이메일 |
| `password_hash` | `VARCHAR(255)` | 아니요 | — | 비밀번호 해시 |
| `name` | `VARCHAR(100)` | 아니요 | — | 회원 이름 |
| `nickname` | `VARCHAR(50)` | 아니요 | — | 화면 표시 닉네임. 중복 허용 |
| `role` | `VARCHAR(20)` | 아니요 | 기본값 'USER' | 권한: USER 또는 ADMIN |
| `status` | `VARCHAR(20)` | 아니요 | 기본값 'ACTIVE' | 상태: ACTIVE 또는 INACTIVE |
| `created_at` | `TIMESTAMP(6)` | 아니요 | — | 최초 저장 시각. JPA Auditing에서 기록 |
| `updated_at` | `TIMESTAMP(6)` | 아니요 | — | 마지막 수정 시각. JPA Auditing에서 기록 |
| `deleted_at` | `TIMESTAMP(6)` | 예 | — | 소프트 삭제 시각. NULL이면 삭제되지 않은 행 |

**제약·관계**

- email은 소프트 삭제 후에도 UNIQUE입니다.
- 이메일·비밀번호 해시·이름·닉네임은 빈 값이 될 수 없습니다.
- deleted_at이 있으면 status는 INACTIVE여야 합니다.

## posts — 게시글

| 컬럼 | 타입 | NULL 허용 | 키·기본값 | 설명 |
| --- | --- | --- | --- | --- |
| `id` | `UUID` | 아니요 | PK | 게시글 UUID. JPA에서 생성 |
| `member_id` | `UUID` | 아니요 | FK → members.id | 작성자 회원 UUID |
| `title` | `VARCHAR(200)` | 아니요 | — | 제목. 최대 200자 |
| `content` | `TEXT` | 아니요 | — | 일반 텍스트 본문. 최대 10000자 |
| `created_at` | `TIMESTAMP(6)` | 아니요 | — | 최초 저장 시각. JPA Auditing에서 기록 |
| `updated_at` | `TIMESTAMP(6)` | 아니요 | — | 마지막 수정 시각. JPA Auditing에서 기록 |
| `deleted_at` | `TIMESTAMP(6)` | 예 | — | 소프트 삭제 시각. NULL이면 삭제되지 않은 행 |

**제약·관계**

- member_id → members.id. 회원 1 : 게시글 N.
- 제목·본문은 공백만 입력할 수 없고, 본문은 10000자 이내입니다.

## comments — 댓글

| 컬럼 | 타입 | NULL 허용 | 키·기본값 | 설명 |
| --- | --- | --- | --- | --- |
| `id` | `UUID` | 아니요 | PK | 댓글 UUID. JPA에서 생성 |
| `post_id` | `UUID` | 아니요 | FK → posts.id | 댓글이 속한 게시글 UUID |
| `member_id` | `UUID` | 아니요 | FK → members.id | 댓글 작성자 회원 UUID |
| `content` | `VARCHAR(1000)` | 아니요 | — | 댓글 내용. 최대 1000자. 공백만 입력 불가 |
| `created_at` | `TIMESTAMP(6)` | 아니요 | — | 최초 저장 시각. JPA Auditing에서 기록 |
| `updated_at` | `TIMESTAMP(6)` | 아니요 | — | 마지막 수정 시각. JPA Auditing에서 기록 |
| `deleted_at` | `TIMESTAMP(6)` | 예 | — | 소프트 삭제 시각. NULL이면 삭제되지 않은 행 |

**제약·관계**

- post_id → posts.id, member_id → members.id. 각각 부모 1 : 댓글 N.
- 게시글·회원의 물리 삭제에 대한 CASCADE는 설정하지 않습니다.

## missing_persons — 실종아동

| 컬럼 | 타입 | NULL 허용 | 키·기본값 | 설명 |
| --- | --- | --- | --- | --- |
| `id` | `UUID` | 아니요 | PK | 서비스 내부 실종아동 UUID. JPA에서 생성 |
| `source_id` | `VARCHAR(30)` | 아니요 | UNIQUE | 경찰청 원본 식별자. 숫자 1~30자리 |
| `name` | `VARCHAR(100)` | 아니요 | — | 이름 |
| `category` | `VARCHAR(3)` | 아니요 | — | 원본 분류 코드. 숫자 3자리. 현재 수집 대상은 아동 010 |
| `sex` | `TEXT` | 예 | — | 원본 성별 값 |
| `occurrence_date` | `TEXT` | 예 | — | 원본 발생일 문자열 |
| `age` | `INTEGER` | 예 | — | 실종 당시 나이 |
| `age_now` | `INTEGER` | 예 | — | 원본에서 제공하는 현재 나이 |
| `address` | `TEXT` | 예 | — | 발생 장소 |
| `clothing` | `TEXT` | 예 | — | 착의 사항 |
| `features` | `TEXT` | 예 | — | 신체 특징 |
| `photo_url` | `VARCHAR(500)` | 예 | — | 기존 공개 API 대표 사진 출처. 사진 파일은 별도 테이블에 저장 |
| `source_available` | `BOOLEAN` | 아니요 | 기본값 TRUE | 최근 전체 수집에 포함된 공개 여부. 발견 완료 여부를 의미하지 않음 |
| `last_seen_at` | `TIMESTAMP(6)` | 아니요 | — | 원본을 마지막으로 수집 확인한 UTC 시각 |
| `created_at` | `TIMESTAMP(6)` | 아니요 | — | 최초 저장 시각. JPA Auditing에서 기록 |
| `updated_at` | `TIMESTAMP(6)` | 아니요 | — | 마지막 수정 시각. JPA Auditing에서 기록 |
| `deleted_at` | `TIMESTAMP(6)` | 예 | — | 소프트 삭제 시각. NULL이면 삭제되지 않은 행 |

**제약·관계**

- source_id는 UNIQUE이며 재동기화 시 같은 아동을 식별하는 기준입니다.
- source_available=false는 공개 중단 상태입니다.

## member_favorites — 관심아동

| 컬럼 | 타입 | NULL 허용 | 키·기본값 | 설명 |
| --- | --- | --- | --- | --- |
| `id` | `UUID` | 아니요 | PK | 관심 등록 UUID. JPA에서 생성 |
| `member_id` | `UUID` | 아니요 | FK → members.id, 복합 UNIQUE | JWT 로그인 정보에서 결정하는 회원 UUID |
| `missing_person_id` | `UUID` | 아니요 | FK → missing_persons.id, 복합 UNIQUE | 서비스 내부 실종아동 UUID. 원본 source_id와 구분 |
| `created_at` | `TIMESTAMP(6)` | 아니요 | — | 최초 저장 시각. JPA Auditing에서 기록 |
| `updated_at` | `TIMESTAMP(6)` | 아니요 | — | 마지막 수정 시각. JPA Auditing에서 기록 |
| `deleted_at` | `TIMESTAMP(6)` | 예 | — | 소프트 삭제 시각. NULL이면 삭제되지 않은 행 |

**제약·관계**

- (member_id, missing_person_id)는 소프트 삭제된 행까지 포함해 UNIQUE입니다.
- 관심 취소는 소프트 삭제, 재등록은 기존 행의 deleted_at을 NULL로 복원합니다.
- 아동 분류 010만 등록하는 규칙은 애플리케이션에서 검증합니다.

## missing_person_images — 경찰청 원본 사진

| 컬럼 | 타입 | NULL 허용 | 키·기본값 | 설명 |
| --- | --- | --- | --- | --- |
| `id` | `UUID` | 아니요 | PK, 복합 UNIQUE | 원본 사진 UUID. JPA에서 생성 |
| `missing_person_id` | `UUID` | 아니요 | FK → missing_persons.id, 복합 UNIQUE | 사진이 속한 실종아동 UUID |
| `sort_order` | `INTEGER` | 아니요 | 복합 UNIQUE | 아동별 원본 순번. 0부터 시작 |
| `source_url` | `VARCHAR(1024)` | 아니요 | — | 출처 추적용 주소. 쿠키 세션 의존 주소이므로 화면에서 직접 사용하지 않음 |
| `content_type` | `VARCHAR(30)` | 아니요 | — | image/jpeg 또는 image/png |
| `content` | `BYTEA` | 아니요 | — | 경찰청에서 수신한 원본 사진 파일 |
| `byte_size` | `INTEGER` | 아니요 | — | 원본 파일 바이트 수. 1~2097152, content 길이와 일치 |
| `sha256` | `VARCHAR(64)` | 아니요 | — | 원본 파일 SHA-256. 소문자 16진수 64자리 |
| `is_main` | `BOOLEAN` | 아니요 | 기본값 FALSE | 대표 원본 여부. 최초에는 첫 활성 순번을 선택 |
| `created_at` | `TIMESTAMP(6)` | 아니요 | — | 최초 저장 시각. JPA Auditing에서 기록 |
| `updated_at` | `TIMESTAMP(6)` | 아니요 | — | 마지막 수정 시각. JPA Auditing에서 기록 |
| `deleted_at` | `TIMESTAMP(6)` | 예 | — | 소프트 삭제 시각. NULL이면 삭제되지 않은 행 |

**제약·관계**

- (missing_person_id, sort_order), (id, missing_person_id)에 각각 복합 UNIQUE를 적용합니다.
- 활성 행(deleted_at IS NULL) 중 is_main=true는 아동별 최대 한 장입니다. 부분 UNIQUE 인덱스로 보장합니다.
- 삭제된 행은 is_main=true가 될 수 없습니다. 대표 삭제 시 남은 첫 활성 사진을 내부 서비스에서 선택합니다.
- missing_person_id → missing_persons.id, ON DELETE CASCADE. 소프트 삭제에는 CASCADE가 적용되지 않습니다.

## missing_person_ai_images — AI 생성 결과 사진

| 컬럼 | 타입 | NULL 허용 | 키·기본값 | 설명 |
| --- | --- | --- | --- | --- |
| `id` | `UUID` | 아니요 | PK | AI 결과 UUID. JPA에서 생성 |
| `missing_person_id` | `UUID` | 아니요 | FK → missing_persons.id, 복합 FK | 대상 실종아동 UUID |
| `source_image_id` | `UUID` | 아니요 | 복합 FK → missing_person_images | 생성에 사용한 경찰청 원본 사진 레코드 UUID. 입력 파일을 복제하지 않음 |
| `target_age` | `INTEGER` | 아니요 | — | 서비스에서 생성 시 지정한 목표 나이. 0~200 |
| `content` | `BYTEA` | 아니요 | — | AI가 생성한 결과 파일. 경찰청 입력 원본이 아님 |
| `content_type` | `VARCHAR(30)` | 아니요 | — | image/jpeg 또는 image/png |
| `byte_size` | `INTEGER` | 아니요 | — | 결과 파일 바이트 수. 1~10485760, content 길이와 일치 |
| `is_main` | `BOOLEAN` | 아니요 | 기본값 FALSE | 대표 AI 여부. 최초 저장 결과를 기본 선택 |
| `created_at` | `TIMESTAMP(6)` | 아니요 | — | 최초 저장 시각. JPA Auditing에서 기록 |
| `updated_at` | `TIMESTAMP(6)` | 아니요 | — | 마지막 수정 시각. JPA Auditing에서 기록 |
| `deleted_at` | `TIMESTAMP(6)` | 예 | — | 소프트 삭제 시각. NULL이면 삭제되지 않은 행 |

**제약·관계**

- missing_person_id → missing_persons.id, ON DELETE CASCADE.
- (source_image_id, missing_person_id) → missing_person_images(id, missing_person_id) 복합 FK로 같은 아동의 원본만 연결합니다.
- 원본 FK에는 ON DELETE CASCADE가 없습니다. 참조 중인 원본의 물리 삭제를 제한하고, 소프트 삭제는 허용합니다.
- 활성 행 중 is_main=true는 아동별 최대 한 장입니다. 삭제된 행은 대표가 될 수 없습니다.
- 아동별 공통 결과이며 회원별 소유 필드는 없습니다. 경찰청 재동기화에서 AI 결과·목표 나이·대표 선택을 덮어쓰지 않습니다.
- source_image_id는 재동기화로 파일이 갱신될 수 있는 원본 레코드 참조입니다. 입력 원본의 별도 버전 스냅샷은 저장하지 않습니다.
