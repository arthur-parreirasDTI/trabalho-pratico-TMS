.PHONY: help up down logs restart clean test-error test-slow test-users

help: ## Mostra esta ajuda
	@echo "Comandos disponíveis:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

up: ## Inicia todos os containers
	docker-compose up --build -d
	@echo "✅ Containers iniciados!"
	@echo "📍 Aplicação: http://localhost:3000"
	@echo "📊 Prometheus: http://localhost:9090"
	@echo "🚨 Alertmanager: http://localhost:9093"
	@echo "📈 Grafana: http://localhost:3001"

down: ## Para todos os containers
	docker-compose down

logs: ## Mostra logs de todos os containers
	docker-compose logs -f

restart: down up ## Reinicia todos os containers

clean: ## Remove containers e volumes
	docker-compose down -v
	@echo "🧹 Limpeza completa realizada!"

test-error: ## Simula erros (dispara alerta)
	@echo "🔴 Gerando erros..."
	@for i in 1 2 3 4 5 6 7 8 9 10; do \
		curl -s http://localhost:3000/simulate/error > /dev/null; \
		sleep 1; \
	done
	@echo "✅ Erros gerados! Verifique o Alertmanager em http://localhost:9093"

test-slow: ## Simula requisições lentas
	@echo "🐌 Gerando requisições lentas..."
	@curl http://localhost:3000/simulate/slow
	@echo "\n✅ Requisição lenta executada!"

test-users: ## Simula pico de usuários
	@echo "👥 Simulando pico de usuários..."
	@for i in 1 2 3 4 5; do \
		curl -s http://localhost:3000/simulate/users; \
		sleep 2; \
	done
	@echo "\n✅ Simulação concluída!"

status: ## Mostra status dos containers
	docker-compose ps
