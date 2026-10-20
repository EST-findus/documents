# 🔎 실종아동 동기화·DB 테스트 가이드

팀원 각자의 컴퓨터에서 **경찰청 요청 → 로컬 DB 저장 → 테스트 페이지에서 정보·사진 조회**를 확인합니다. 데이터가 포함된 HTML·JSON 파일은 생성하지 않습니다.

## ⏱️ 예상 소요 시간

Git·JDK 17·Docker Desktop이 설치된 환경 기준입니다. 설치 시간은 별도이며 네트워크와 컴퓨터 성능에 따라 달라집니다.

| 작업 | 예상 시간 |
| --- | --- |
| 소스 받기·개인 `.env` 설정 | 3~10분 |
| Docker 실행 | 이미지가 있으면 30초~2분, 처음 다운로드하면 3~10분 |
| 백엔드 실행·Flyway 테이블 생성 | 보통 30초~2분, 최초 라이브러리 다운로드 시 2~5분 이상 |
| 경찰청 데이터·사진 전체 동기화 | 약 3~6분 |
| 페이지·사진·DB 확인 | 1~2분 |
| **처음 설정부터 완료까지** | **약 10~30분** |
| **설정 완료 후 반복 검증** | **약 5~10분** |

이전 실측은 **아동 168명·사진 337장 기준 약 3분 30초~4분 10초**였습니다. 이때 정상 수집 요청은 목록 API 2회 + 상세 페이지 168회 + 사진 337회 = 총 507회였습니다. 인증키를 사용하는 목록 API는 2회이며 나머지는 일반 웹 요청입니다. 건수·사진 수·재시도·경찰청 응답 속도에 따라 달라집니다. 시간 초과를 피하려고 반복 클릭하지 마세요.

## 1️⃣ 소스 준비

이 기능이 `dev`에 병합된 뒤 아래 명령을 실행합니다. 병합 전 검증은 PR의 `feat/safedream-image-sync` 브랜치를 사용합니다.

새로 받는 경우:

```bash
git clone https://github.com/EST-findus/findus-backend.git
cd findus-backend
git switch dev
```

이미 받은 경우에는 **백엔드 폴더**에서 실행합니다. 작업 중인 변경이 있다면 먼저 커밋하거나 별도 보관하세요.

```bash
git status
git switch dev
git pull --ff-only origin dev
```

이후 명령은 모두 `build.gradle`·`docker-compose.yml`이 있는 `findus-backend` 폴더에서 실행합니다. `documents`나 상위 `FindUs` 폴더가 아닙니다.

## 2️⃣ 개인 `.env` 설정

처음에만 예제 파일을 복사합니다. 기존 `.env`는 덮어쓰지 않습니다.

**macOS:**

```bash
[ -f .env ] || cp .env.example .env
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
java -version
openssl rand -base64 32
```

마지막 명령의 출력값을 `JWT_SECRET`에 입력합니다.

**Windows PowerShell:**

```powershell
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
java -version
$bytes = New-Object byte[] 32
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($bytes)
[Convert]::ToBase64String($bytes)
$rng.Dispose()
```

Java 17이 출력되어야 합니다. Windows에서 다른 버전이 나오면 JDK 17의 `JAVA_HOME`·`Path` 설정 또는 IntelliJ의 프로젝트·Gradle JVM을 확인합니다. 출력된 무작위 키는 `JWT_SECRET`에 입력합니다.

`.env`에서 아래 값을 확인합니다. 비밀번호와 키에 실제 값을 입력하고 Git에 올리지 않습니다. 값에 따옴표를 붙이지 않습니다.

| 설정 | 입력 내용 |
| --- | --- |
| `POSTGRES_PASSWORD` | 개인 로컬 DB 비밀번호 |
| `REDIS_PASSWORD` | 개인 로컬 Redis 비밀번호 |
| `JWT_SECRET` | 위에서 생성한 Base64 키. 이 테스트가 비회원이어도 서버 시작 설정에는 필요 |
| `PROMETHEUS_PASSWORD` | 로컬 모니터링 비밀번호 |
| `GRAFANA_ADMIN_PASSWORD` | 로컬 Grafana 최초 비밀번호 |
| `SAFE182_ESNTL_ID` | 경찰청 발급 ID |
| `SAFE182_AUTH_KEY` | 경찰청 발급 인증키 |
| `SAFE182_BASE_URL` | `https://www.safe182.go.kr` |
| `MISSING_SCHEDULE_ENABLED` | `false`: 검증 중에는 수동 실행만 사용 |

예약 실행 여부는 비밀정보가 아니라 환경마다 바꾸는 실행 설정입니다. 설정 파일 기본값도 `false`이며 `.env`에서 변경할 수 있습니다. 경찰청 인증정보는 팀에서 허용한 비공개 경로로 전달받습니다.

깨끗한 DB 검증에 가상 회원·게시글이 필요 없으면 아래 두 항목도 `false`로 설정합니다. 실종아동 수집과는 별개 기능입니다.

```dotenv
DUMMY_DATA_ENABLED=false
DUMMY_STARTUP_ENABLED=false
```

## 3️⃣ Docker 실행

Docker Desktop을 켠 다음 실행합니다.

```bash
docker compose up -d --wait
docker compose ps
```

PostgreSQL·Redis·Prometheus·Grafana·exporter 2개가 실행됩니다. 이 과정만으로 경찰청 데이터가 들어오지는 않습니다. 기존 볼륨은 그대로 사용할 수 있습니다.

## 4️⃣ 백엔드 실행

**macOS:**

```bash
./gradlew bootRun --args='--spring.profiles.active=local'
```

**Windows PowerShell:**

```powershell
.\gradlew.bat bootRun --args='--spring.profiles.active=local'
```

또는 IntelliJ에서 JDK·Gradle JVM을 17로 지정하고 `FindUsApplication`을 실행합니다. 실행 프로필은 `local`, 작업 폴더는 `findus-backend`로 지정합니다. 서버는 한 번만 실행하고 실행한 터미널은 유지합니다.

`Started FindUsApplication` 로그가 나오면 [헬스체크](http://localhost:18080/health)를 확인합니다. Flyway가 기존 마이그레이션과 V9를 적용해 테이블을 생성합니다. 테이블이 비어 있어도 정상이며 서버 시작만으로 경찰청 동기화를 실행하지 않습니다.

## 5️⃣ 테스트 페이지 열기

👉 **http://localhost:18080/test/safe182**

- 회원가입·로그인·Authorize·CSRF 준비가 필요 없습니다.
- 신규 DB는 전체 0명과 ‘저장된 실종아동이 없습니다’가 표시됩니다.
- 기존 데이터가 있으면 DB의 현재 공개 정보를 표시합니다.
- `file://.../safe182-preview.html`을 직접 열지 않습니다. 파일 자체에는 데이터가 없으며 서버 주소로 안내합니다.
- 페이지는 `local` 프로필에서만 제공합니다. `SERVER_PORT`를 변경했다면 URL의 포트도 변경합니다.

## 6️⃣ 실제 경찰청 요청·DB 저장

페이지에서 **‘경찰청 동기화 → DB 저장’**을 한 번 누르고 완료까지 기다립니다. 진행 중 버튼은 비활성화되며 완료 후 DB를 자동 재조회합니다.

터미널로 실행하려면 새 터미널의 백엔드 폴더에서 아래 명령을 사용합니다. **페이지 버튼과 curl 중 하나만 실행합니다.**

**macOS:**

```bash
curl -X POST http://localhost:18080/api/admin/missing-sync
```

**Windows PowerShell:**

```powershell
curl.exe -X POST http://localhost:18080/api/admin/missing-sync
```

curl이 완료된 뒤 페이지의 **‘DB 새로고침’**을 누릅니다. Swagger에서도 해당 POST를 인증 없이 실행할 수 있습니다. 만료된 Authorize 토큰이 남아 있다면 Logout으로 지웁니다. 브라우저 주소창은 GET 요청이므로 동기화를 실행하지 않습니다.

성공 응답은 `status: COMPLETED`입니다. `counts.received`는 수신한 아동 수, `imagesSaved`는 수신·반영한 사진 수, `photoFailures`는 사진을 전부 확인하지 못한 아동 수입니다. `COMPLETED`라도 `photoFailures`가 0보다 크면 사진 일부를 확인하지 못한 상태입니다. 기존 사진은 보존하며 다음 동기화에서 다시 시도합니다. `counts.requests.total`은 재시도를 포함한 실제 외부 HTTP 요청 수입니다.

전체 데이터 API 오류나 DB 오류는 전체 반영을 롤백합니다. `FAILED`는 서버 로그·이력을 확인하고, 응답 대기 시간 초과는 작업이 끝났다고 단정하지 말고 먼저 아래 이력과 DB를 확인합니다.

동기화 이력: **http://localhost:18080/api/admin/missing-sync**

## 7️⃣ DB 조회·사진·페이지 이동 확인

다음을 확인합니다.

- 전체 아동 수와 각 아동의 번호·이름·DB UUID가 표시된다.
- 한 페이지에 최대 10명, 페이지 번호는 10개 단위로 이동한다.
- 여러 장이 저장된 아동은 사진이 모두 표시된다.
- 사진이 없으면 ‘저장된 사진 없음’, 이미지 API 오류면 ‘사진 조회 실패’로 구분된다.
- ‘DB 새로고침’과 페이지 이동은 경찰청 재요청 없이 우리 DB만 조회한다.
- 백엔드를 재시작해도 저장한 데이터·사진이 조회된다. Docker 컨테이너를 다시 켜도 볼륨을 삭제하지 않았다면 유지된다.

JSON 직접 조회: **http://localhost:18080/api/missing-persons?page=0&size=10**

응답의 `images[].url` 앞에 `http://localhost:18080`을 붙이면 DB에 저장된 사진 원본을 직접 확인할 수 있습니다. 경찰청에 다시 요청하는 경로가 아닙니다.

## 8️⃣ PostgreSQL에서 저장 확인

일반 터미널에서:

```bash
docker compose exec postgres psql -U findus -d findus -p 15432
```

Docker Desktop의 PostgreSQL **Exec 화면**에서는:

```bash
psql -U findus -d findus -p 15432
```

`findus=#`가 표시된 다음 아래 명령을 입력합니다. 셸의 `#` 상태에서 `\dt`를 실행하면 안 됩니다. DB 계정·이름·포트를 변경했다면 접속 명령도 맞춰주세요.

```sql
-- 테이블 목록과 사진 외래키 구조 확인
\dt findus.*
\d findus.missing_person_images

-- 현재 공개된 아동 수
SELECT COUNT(*) FROM findus.missing_persons
WHERE source_available = true AND deleted_at IS NULL;

-- 현재 공개된 아동의 활성 사진 수
SELECT COUNT(*)
FROM findus.missing_person_images i
JOIN findus.missing_persons p ON p.id = i.missing_person_id
WHERE i.deleted_at IS NULL
  AND p.source_available = true AND p.deleted_at IS NULL;

-- 아동별 사진 연결 확인
SELECT p.id, p.source_id, p.name, COUNT(i.id) AS photo_count
FROM findus.missing_persons p
LEFT JOIN findus.missing_person_images i
  ON i.missing_person_id = p.id AND i.deleted_at IS NULL
WHERE p.source_available = true AND p.deleted_at IS NULL
GROUP BY p.id
ORDER BY photo_count DESC
LIMIT 10;

-- 종료
\q
```

긴 결과 화면은 `q`로 닫거나 `\pset pager off`로 페이지 표시를 끌 수 있습니다. 사진 원본은 BYTEA이므로 `SELECT *` 대신 위처럼 필요한 필드만 조회합니다.

## 🧹 선택: DB를 비우고 처음부터 검증

**개인 로컬 DB의 모든 회원·게시글·댓글·실종아동·사진·배치 이력이 삭제됩니다. 필요한 데이터가 없는 경우에만 실행합니다. 기본 테스트에 볼륨 삭제는 필요하지 않습니다.**

백엔드를 먼저 종료합니다. 이후 백엔드 폴더에서:

```bash
docker compose down
docker volume rm findus-local_postgres_data
docker compose up -d --wait
```

다른 서비스의 볼륨은 유지합니다. 볼륨 이름이 다르면 `docker volume ls`에서 이 프로젝트의 PostgreSQL 볼륨을 확인합니다. `docker compose down -v`는 모든 Compose 볼륨을 삭제하므로 이 절차에서는 사용하지 않습니다.

다시 4단계부터 진행하면 **테이블 생성 → 0명 표시 → 동기화 → DB 저장·조회**를 확인할 수 있습니다.

## 🛠️ 자주 막히는 부분

| 증상 | 확인 방법 |
| --- | --- |
| 페이지가 401·404 | 최신 코드인지, 기존 서버를 재시작했는지, `local` 프로필인지 확인 |
| 동기화만 401 | Swagger에 남은 만료 토큰을 지우거나 인증 없는 페이지 버튼·curl로 실행 |
| `root execution … not permitted` | Exec에서 `postgres psql …`이 아니라 `psql …`만 입력 |
| `dt: not found` | 아직 셸임. psql 접속 후 `findus=#`에서 `\dt findus.*` 실행 |
| DB 비밀번호 오류 | `.env` 값과 기존 볼륨 생성 당시 DB 비밀번호가 같은지 확인. `.env`만 수정해도 기존 DB 비밀번호가 바뀌지는 않음 |
| 테이블이 없음 | 백엔드의 Flyway·DB 연결 오류 확인. 데이터 수집 전에도 서버 정상 시작 후 테이블은 존재해야 함 |
| 동기화가 오래 걸림 | 이력·서버 로그 확인. 중복 클릭하지 않음. 외부 사이트 장애 시 예상 시간보다 길어질 수 있음 |
| 사진 일부 확인 미완료 | 정상 사진·기존 사진은 유지됨. 외부 응답 정상화 후 재동기화 |

## 🚀 배포 전 변경 사항

현재 동기화 실행·이력 조회는 MVP 테스트를 위해 비회원에게 허용합니다. `SecurityConfig`와 `MissingBatchController`의 `// TODO 배포 전`을 찾아 다음을 복원해야 합니다.

- 동기화 POST·GET에 관리자 권한 `hasRole("ADMIN")` 적용
- 동기화 POST의 CSRF 예외 제거
- Swagger의 관리자 인증 요구 복원

확인 페이지는 `local` 프로필 전용입니다. 실제 개인정보·사진·인증키가 포함된 파일을 문서 저장소에 올리지 않습니다.
