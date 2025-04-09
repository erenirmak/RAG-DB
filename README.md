# RAG-DB

Custom PostgreSQL database image. It has both pgvector (vector database to store embeddings) and age (graph database to store graph structure) extensions activated.

Base image: pgvector/pgvector:pg16 (PostgreSQL 16 with pgvector extension)

Additional Extension: Apache AGE (Graph database)

You can directly pull this image:

docker pull erenirmak/pgvector-age
