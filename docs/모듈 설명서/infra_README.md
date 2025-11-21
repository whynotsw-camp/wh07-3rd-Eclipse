# Infrastructure

인프라 레이어로, 데이터베이스, 캐시, 외부 API 등 외부 시스템과의 연동을 담당합니다.

## 구조

```
infra/
├── database/                 # 데이터베이스
│   ├── repository/          # Repository 패턴
│   └── tables/              # SQLAlchemy 테이블 정의
├── cache/                   # Redis 캐시
│   ├── redis_connector.py   # Redis 연결
│   └── redis_repository.py  # Redis 세션 관리
├── external/                # 외부 API
│   ├── kakao_map.py        # 카카오맵 API
│   ├── weather_api.py      # 날씨 API
│   └── query_enchantment.py # GPT-4 API
└── vector_database/         # ChromaDB (벡터 DB)
    └── chroma_connector.py  # ChromaDB 연결
```

## Database

### Repository

모든 데이터베이스 접근은 Repository 패턴을 통해 이루어집니다.

#### base_repository.py

공통 CRUD 메서드를 제공하는 기본 클래스

```python
class BaseRepository:
    async def insert(self, item) -> bool
    async def select(self, **filters) -> list
    async def update(self, item_id, item) -> bool
    async def delete(self, **filters) -> bool
```

사용 예시:

```python
from src.infra.database.repository.user_repository import UserRepository

repo = UserRepository()
users = await repo.select(age=25, city='Seoul')
```

상세 사용법: [repository.md](../../outputs/repository.md)

#### 주요 Repository

```
repository/
├── base_repository.py
├── maria_engine.py
├── category_repository.py          # 매장
├── category_tags_repository.py     # 매장-태그
├── tags_repository.py              # 태그
├── user_repository.py              # 사용자
├── user_like_repository.py         # 찜
├── user_history_repository.py      # 일정표
├── merge_history_repository.py     # 병합 히스토리
├── reviews_repository.py           # 리뷰
├── black_repository.py             # 블랙리스트
└── statistics_repository.py        # 통계
```

### Tables

SQLAlchemy를 사용한 테이블 정의

```python
from sqlalchemy import Table, Column, String, Integer, MetaData

meta = MetaData()

users_table = Table(
    'users',
    meta,
    Column('id', String(255), primary_key=True),
    Column('username', String(255)),
    Column('email', String(255)),
    # ...
)
```

#### 테이블 목록

```
tables/
├── table_users.py              # 사용자
├── table_category.py           # 매장
├── table_category_tags.py      # 매장-태그 관계
├── table_tags.py               # 태그
├── table_reviews.py            # 리뷰
├── table_user_like.py          # 찜
├── table_user_history.py       # 일정표
├── table_merge_history.py      # 병합 히스토리
└── table_black.py              # 블랙리스트
```

### 데이터베이스 연결

#### maria_engine.py

MariaDB 연결 엔진 관리

```python
from src.infra.database.repository.maria_engine import get_engine

engine = await get_engine()
async with engine.begin() as conn:
    result = await conn.execute(stmt)
```

특징:
- 비동기 연결 풀 사용
- 설정 파일 기반 (database_config.json)
- 자동 재연결

## Cache (Redis)

### redis_connector.py

Redis 연결 관리

```python
from src.infra.cache.redis_connector import RedisConnector

redis = RedisConnector()
await redis.connect()

# 사용
client = await redis.get_client()
await client.set("key", "value")
```

특징:
- 싱글톤 패턴
- 비동기 연결
- 자동 재연결

### redis_repository.py

세션 관리용 Repository

#### SessionRepository

JWT 세션 관리

```python
from src.infra.cache.redis_repository import SessionRepository

repo = SessionRepository()

# 세션 저장
await repo.set_session(
    session_id="token123",
    user_id="user123",
    token_type="access",
    ttl=3600
)

# 세션 조회
session = await repo.get_session("token123")

# 세션 삭제
await repo.delete_session("token123")
```

메서드:
- `set_session()`: 세션 저장 (TTL 설정)
- `get_session()`: 세션 조회
- `delete_session()`: 세션 삭제
- `exists_session()`: 세션 존재 확인

#### AI 채팅 세션

```python
# 채팅 세션 저장
await repo.set_chat_session(
    user_id="user123",
    chat_data={
        "stage": "collecting_details",
        "selectedCategories": ["음식점"],
        # ...
    },
    ttl=1800  # 30분
)

# 채팅 세션 조회
chat = await repo.get_chat_session("user123")

# 채팅 세션 삭제
await repo.delete_chat_session("user123")
```

메서드:
- `set_chat_session()`: 채팅 세션 저장
- `get_chat_session()`: 채팅 세션 조회
- `delete_chat_session()`: 채팅 세션 삭제
- `refresh_chat_session()`: TTL 갱신

## External APIs

### kakao_map.py

카카오맵 API 연동

```python
from src.infra.external.kakao_map import get_walking_route

result = await get_walking_route(
    origin="127.123,37.123",
    destination="127.456,37.456"
)
# {"distance": 1500, "duration": 1200}
```

기능:
- 도보 경로 검색
- 자동차 경로 검색

### weather_api.py

공공데이터 날씨 API

```python
from src.infra.external.weather_api import get_weather

weather = await get_weather(
    nx=60,
    ny=127,
    base_date="20240101",
    base_time="0600"
)
```

### query_enchantment.py

GPT-4 API 연동

```python
from src.infra.external.query_enchantment import QueryEnhancementService

service = QueryEnhancementService()

# 입력 검증
result_type, error = await service.validate_user_input(
    user_message="분위기 좋은 곳",
    category="음식점"
)

# 태그 추출
tags = await service.extract_tags_from_message(
    user_message="조용하고 분위기 좋은 곳",
    category="음식점",
    people_count=2
)

# 매장 필터링
filtered = await service.filter_recommendations_with_gpt(
    stores=candidates,
    user_keywords=["분위기 좋은"],
    category_type="음식점",
    personnel=2
)
```

상세 내용: [external.md](../../outputs/external.md)

## Vector Database (ChromaDB)

### chroma_connector.py

ChromaDB 연결 및 컬렉션 관리

```python
from src.infra.vector_database.chroma_connector import get_chroma_client

client = await get_chroma_client()
collection = await client.get_collection("stores")

# 검색
results = await collection.query(
    query_texts=["분위기 좋은 음식점"],
    n_results=15
)
```

특징:
- 로컬/원격 모드 지원
- 비동기 API
- intfloat/multilingual-e5-large 임베딩

## 설정 파일

모든 설정 파일은 `src/resources/config/`에 위치:

### database_config.json

```json
{
  "host": "localhost",
  "port": 3306,
  "user": "root",
  "password": "password",
  "database": "mydb"
}
```

### redis_config.json

```json
{
  "host": "localhost",
  "port": 6379,
  "db": 0
}
```

### .env

```env
PUBLIC_KEY=your_jwt_secret_key
ISSUE_NAME=your_service_name
KAKAO_REST_API_KEY=your_kakao_key
OPENAI_API_KEY=your_openai_key
WEATHER_API_KEY=your_weather_key
TMAP_API_KEY=your_tmap_key
```

### chroma_config.json

```json
{
  "mode": "local",
  "path": "./chroma_db",
  "collection_name": "stores"
}
```

## 설정 로드

path.py에서 중앙 관리:

```python
from src.utils.path import path_dic

config_path = path_dic["database_config"]
env_path = path_dic["env"]
```

## 연결 초기화

### 시작 시 (main.py)

```python
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Redis 연결
    redis_client = RedisConnector()
    await redis_client.connect()
    
    yield
    
    # 종료 시 정리
    await close_redis()
```

### 사용 시

```python
# Database
engine = await get_engine()

# Redis
redis = await RedisConnector().get_client()

# ChromaDB
chroma = await get_chroma_client()
```

## 트랜잭션 처리

### Database

```python
engine = await get_engine()
async with engine.begin() as conn:
    # 여러 쿼리 실행
    await conn.execute(stmt1)
    await conn.execute(stmt2)
    # 자동 커밋/롤백
```

### Redis

Redis는 단일 명령이므로 트랜잭션 불필요
(필요시 MULTI/EXEC 사용)

## 에러 처리

### Database

```python
try:
    result = await repo.select(id='user123')
except Exception as e:
    logger.error(f"Database error: {e}")
    raise
```

### Redis

```python
try:
    value = await redis.get("key")
except ConnectionError:
    logger.error("Redis connection failed")
    # 폴백 로직
```

### External API

```python
try:
    result = await external_api.call()
except requests.RequestException as e:
    logger.error(f"API call failed: {e}")
    # 폴백 또는 재시도
```

## 성능 최적화

### 1. 연결 풀 사용

Database와 Redis 모두 연결 풀 사용

### 2. 비동기 처리

모든 I/O 작업은 async/await 사용

### 3. 캐싱

Redis를 활용한 세션 캐싱

### 4. 벡터 검색

ChromaDB를 통한 빠른 유사도 검색