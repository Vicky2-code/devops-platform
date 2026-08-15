.PHONY: backend frontend test lint build cli doctor ubuntu-compose \
        mon-compose infra-init infra-plan infra-apply k8s-apply help

help:
	@echo "devflow targets:"
	@echo "  backend      run backend (uvicorn, port 8000)"
	@echo "  frontend     run frontend dev server (vite, port 5173)"
	@echo "  test         run backend pytest suite"
	@echo "  lint         ruff check backend"
	@echo "  build        build frontend production bundle"
	@echo "  cli          show CLI help"
	@echo "  doctor       run CLI environment checks"

backend:
	cd backend && uvicorn app.main:app --reload --port 8000

frontend:
	cd frontend && npm run dev

test:
	cd backend && python -m pytest -v

lint:
	cd backend && ruff check app tests

build:
	cd frontend && npm run build

cli:
	./scripts/devflow help

doctor:
	./scripts/devflow doctor

compose:
	docker compose up --build -d

mon-compose:
	docker compose -f docker-compose.monitoring.yml up -d

infra-init:
	cd infra/terraform && terraform init

infra-plan:
	cd infra/terraform && terraform plan

infra-apply:
	cd infra/terraform && terraform apply

k8s-apply:
	kubectl apply -f k8s/