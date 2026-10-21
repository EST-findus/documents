# 📚 FindUs Documents

FindUs의 기획·요구사항·발표자료·ERD·화면 목업·API 명세서를 관리하는 문서 저장소입니다.

| 폴더 | 자료 |
| --- | --- |
| [erd](erd/) | [ERD v2](erd/erd_v2.png), [ERD v3](erd/erd_v3.png), [v3 Import SQL](erd/erd_v3.sql), [테이블 명세서](erd/README.md) |
| [ppt](ppt/) | 중간발표 등 발표자료 |
| [prd](prd/) | 요구사항 정의서·PRD |
| [mockup/v1](mockup/v1/) | 화면 설계 목업 이미지 11개 |
| [api](api/) | [API 명세서 v1](api/API명세서_v1.pdf) |
| [planning](planning/) | 기존 기획서·원페이지 리포트 및 참고자료 |
| [research](research/) | 서비스 비교·조사자료 |
| [prompt](prompt/) | 데일리 스크럼 등 공용 프롬프트 |
| [guides](guides/) | [실종아동 테스트](guides/safedream-local-test.md), [대표 사진·AI 저장 구조](guides/ai-image-storage.md) |

## 🗂️ 자료 관리

- 화면 설계는 `mockup/v1/`의 번호순 이미지를 확인합니다.
- API 명세서 PDF는 작성 당시의 스냅샷입니다. 최신 API 확인·호출은 백엔드 실행 후 [Swagger](http://localhost:18080/swagger-ui/index.html)를 사용합니다.

- ERDCloud에서는 [erd_v3.sql](erd/erd_v3.sql)을 Import하여 최신 테이블과 관계를 확인합니다. [v2 SQL](erd/erd_v2.sql)은 이전 6개 테이블 구조입니다. Import용 SQL은 실제 DB 변경에는 사용하지 않습니다.
- ERD 이미지는 [v1](erd/erd_261016_v1.png)·[v2](erd/erd_v2.png)·[v3](erd/erd_v3.png)로 보관합니다. 첨부 이미지는 작성 당시의 도식이며, 최신 7개 엔티티의 정확한 컬럼·외래키는 [테이블 명세서](erd/README.md), [Mermaid 원본](erd/erd.mmd), v3 SQL을 기준으로 확인합니다.
- 발표자료는 `ppt/`, 요구사항 정의서는 `prd/`에 저장합니다. 기존 `planning/` 자료는 이력과 참고용으로 유지합니다.
- 자료를 수정할 때 해당 문서의 버전과 변경 내용을 커밋·PR에 남깁니다.

## 🔗 코드 저장소

- [백엔드](https://github.com/EST-findus/findus-backend): 코드·환경설정·실행 안내와 실제 DB 변경용 Flyway 마이그레이션을 관리합니다.
- 프로젝트 문서와 실제 DB 구조가 달라지면 ERD와 요구사항 정의서를 함께 검토합니다.
