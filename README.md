# 📚 FindUs Documents

FindUs의 기획·요구사항·발표자료·ERD·화면 목업·API 명세서를 관리하는 문서 저장소입니다.

| 폴더 | 자료 |
| --- | --- |
| [erd](erd/) | ERD 이미지, Mermaid 원본, ERDCloud Import용 SQL |
| [ppt](ppt/) | 중간발표 등 발표자료 |
| [prd](prd/) | 요구사항 정의서·PRD |
| [Mockup](Mockup/) | 화면 설계 목업 이미지 11개 |
| [api](api/) | [API 명세서 v1](api/API명세서_v1.pdf) |
| [planning](planning/) | 기존 기획서·원페이지 리포트 및 참고자료 |
| [research](research/) | 서비스 비교·조사자료 |
| [prompt](prompt/) | 데일리 스크럼 등 공용 프롬프트 |

## 🗂️ 자료 관리

- 화면 설계는 `Mockup/`의 번호순 이미지를 확인합니다.
- API 명세서 PDF는 작성 당시의 스냅샷입니다. 최신 API 확인·호출은 백엔드 실행 후 [Swagger](http://localhost:18080/swagger-ui/index.html)를 사용합니다.

- ERDCloud에서는 [erdcloud-import.sql](erd/erdcloud-import.sql)을 Import하여 테이블과 관계를 확인합니다. 이 파일은 ERD 작성용이며 실제 DB 변경에는 사용하지 않습니다.
- ERD 원본은 [erd.mmd](erd/erd.mmd)이며, 이미지는 `erd/`에서 함께 관리합니다.
- 발표자료는 `ppt/`, 요구사항 정의서는 `prd/`에 저장합니다. 기존 `planning/` 자료는 이력과 참고용으로 유지합니다.
- 자료를 수정할 때 해당 문서의 버전과 변경 내용을 커밋·PR에 남깁니다.

## 🔗 코드 저장소

- [백엔드](https://github.com/EST-findus/findus-backend): 코드·환경설정·실행 안내와 실제 DB 변경용 Flyway 마이그레이션을 관리합니다.
- 프로젝트 문서와 실제 DB 구조가 달라지면 ERD와 요구사항 정의서를 함께 검토합니다.
