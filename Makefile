.PHONY: help up down logs restart clean status
.PHONY: test-all test-error test-slow test-users test-memory test-app-down
.PHONY: watch-alerts watch-metrics check-alerts

help: ## Mostra esta ajuda
	@echo ""
	@echo "╔══════════════════════════════════════════════════════╗"
	@echo "║         Comandos DevOps Monitoring                  ║"
	@echo "╚══════════════════════════════════════════════════════╝"
	@echo ""
	@echo "📦 GERENCIAMENTO:"
	@grep -E '^(up|down|restart|clean|logs|status):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "🚨 TESTES DE ALERTAS:"
	@grep -E '^test-.*:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[33m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "👀 MONITORAMENTO:"
	@grep -E '^(watch-alerts|watch-metrics|check-alerts):.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[32m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

up: ## Inicia todos os containers
	docker-compose up --build -d
	@echo ""
	@echo "✅ Containers iniciados!"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  📍 Aplicação:     http://localhost:3000"
	@echo "  📊 Prometheus:    http://localhost:9090"
	@echo "  🚨 Alertmanager:  http://localhost:9093"
	@echo "  📈 Grafana:       http://localhost:3001 (admin/admin)"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "💡 Teste os alertas: make test-all"
	@echo ""

down: ## Para todos os containers
	docker-compose down

logs: ## Mostra logs de todos os containers
	docker-compose logs -f

restart: down up ## Reinicia todos os containers

clean: ## Remove containers e volumes
	docker-compose down -v
	@echo "🧹 Limpeza completa realizada!"

status: ## Mostra status dos containers
	@docker-compose ps

# ============================================
# 🚨 TESTES DE ALERTAS
# ============================================

test-all: ## Executa TODOS os testes de alerta sequencialmente
	@echo ""
	@echo "╔══════════════════════════════════════════════════════╗"
	@echo "║     Executando TODOS os Testes de Alerta            ║"
	@echo "╚══════════════════════════════════════════════════════╝"
	@echo ""
	@$(MAKE) test-error
	@sleep 10
	@$(MAKE) test-slow
	@sleep 10
	@$(MAKE) test-users
	@sleep 10
	@$(MAKE) test-memory
	@echo ""
	@echo "✅ Todos os testes executados!"
	@echo "🔍 Verifique os alertas: make check-alerts"
	@echo ""

test-error: ## ⚠️ Dispara alerta HighErrorRate (>0.5 erros/s por 30s)
	@echo ""
	@echo "🔴 Teste: HighErrorRate"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Condição: > 0.5 erros/segundo por 30 segundos"
	@echo "Estratégia: 2 erros/segundo por 60 segundos"
	@echo ""
	@echo "Iniciando em 3 segundos..."
	@sleep 3
	@echo "▶️  Gerando erros contínuos..."
	@for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60; do \
		curl -s http://localhost:3000/simulate/error > /dev/null 2>&1 & \
		curl -s http://localhost:3000/simulate/error > /dev/null 2>&1 & \
		sleep 1; \
		if [ $$((i % 10)) -eq 0 ]; then echo "  [$$i/60s] Erros gerados..."; fi; \
	done
	@echo ""
	@echo "✅ Teste concluído!"
	@echo "⏳ Aguarde ~30s para o alerta disparar"
	@echo "🔍 Verifique: http://localhost:9093 ou make check-alerts"
	@echo ""

test-slow: ## ⚠️ Dispara alerta SlowRequests (>1s por 1min)
	@echo ""
	@echo "🐌 Teste: SlowRequests"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Condição: 95% das requisições > 1 segundo por 1 minuto"
	@echo "Estratégia: 30 requisições lentas (2s cada)"
	@echo ""
	@echo "Iniciando em 3 segundos..."
	@sleep 3
	@echo "▶️  Gerando requisições lentas..."
	@for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30; do \
		curl -s http://localhost:3000/simulate/slow > /dev/null 2>&1 & \
		if [ $$((i % 5)) -eq 0 ]; then echo "  [$$i/30] Requisições lentas..."; fi; \
		sleep 2; \
	done
	@echo ""
	@echo "✅ Teste concluído!"
	@echo "⏳ Aguarde ~1min para o alerta disparar"
	@echo "🔍 Verifique: http://localhost:9093 ou make check-alerts"
	@echo ""

test-users: ## ℹ️ Dispara alerta HighActiveUsers (>150 users por 30s)
	@echo ""
	@echo "👥 Teste: HighActiveUsers"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Condição: > 150 usuários ativos por 30 segundos"
	@echo "Estratégia: Manter alto número de usuários por 45s"
	@echo ""
	@echo "Iniciando em 3 segundos..."
	@sleep 3
	@echo "▶️  Simulando pico de usuários..."
	@for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do \
		curl -s http://localhost:3000/simulate/users > /dev/null 2>&1; \
		if [ $$((i % 5)) -eq 0 ]; then echo "  [$$i/15] Pico mantido..."; fi; \
		sleep 3; \
	done
	@echo ""
	@echo "✅ Teste concluído!"
	@echo "⏳ Aguarde ~30s para o alerta disparar"
	@echo "🔍 Verifique: http://localhost:9093 ou make check-alerts"
	@echo ""

test-memory: ## ⚠️ Dispara alerta HighMemoryUsage (>100MB por 1min)
	@echo ""
	@echo "💾 Teste: HighMemoryUsage"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Condição: > 100MB de memória por 1 minuto"
	@echo "Estratégia: Forçar coleta de métricas de memória"
	@echo ""
	@echo "Iniciando em 3 segundos..."
	@sleep 3
	@echo "▶️  Registrando uso de memória..."
	@for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do \
		curl -s http://localhost:3000/simulate/memory > /dev/null 2>&1; \
		if [ $$((i % 5)) -eq 0 ]; then echo "  [$$i/20] Memória registrada..."; fi; \
		sleep 3; \
	done
	@echo ""
	@echo "✅ Teste concluído!"
	@echo "⏳ Aguarde ~1min para o alerta disparar"
	@echo "🔍 Verifique: http://localhost:9093 ou make check-alerts"
	@echo ""

test-app-down: ## 🔴 Dispara alerta ApplicationDown (app offline por 30s)
	@echo ""
	@echo "💀 Teste: ApplicationDown"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Condição: Aplicação fora do ar por 30 segundos"
	@echo "Estratégia: Parar container por 45 segundos"
	@echo ""
	@read -p "⚠️  Isso vai parar a aplicação por 45s. Continuar? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "▶️  Parando aplicação..."; \
		docker-compose stop app; \
		echo "⏳ Aguardando 45 segundos..."; \
		sleep 45; \
		echo "▶️  Reiniciando aplicação..."; \
		docker-compose start app; \
		echo ""; \
		echo "✅ Teste concluído!"; \
		echo "🔍 Verifique: http://localhost:9093 ou make check-alerts"; \
	else \
		echo "❌ Teste cancelado"; \
	fi
	@echo ""

# ============================================
# 👀 MONITORAMENTO
# ============================================

watch-alerts: ## Monitora alertas em tempo real
	@echo "👀 Monitorando alertas (Ctrl+C para sair)..."
	@echo ""
	@watch -n 2 'curl -s http://localhost:9093/api/v2/alerts 2>/dev/null | python3 -m json.tool 2>/dev/null | grep -E "(alertname|state|startsAt)" || echo "Nenhum alerta ativo"'

watch-metrics: ## Monitora métricas em tempo real
	@echo "📊 Monitorando métricas principais (Ctrl+C para sair)..."
	@echo ""
	@watch -n 2 'echo "=== MÉTRICAS ===" && curl -s http://localhost:3000/metrics 2>/dev/null | grep -E "(app_errors_total|app_active_users|app_memory_usage_bytes|http_requests_total)" | head -10'

check-alerts: ## Verifica alertas ativos no momento
	@echo ""
	@echo "🔍 Verificando alertas ativos..."
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@ALERTS=$$(curl -s http://localhost:9093/api/v2/alerts 2>/dev/null); \
	if [ "$$ALERTS" = "[]" ]; then \
		echo "✅ Nenhum alerta ativo no momento"; \
	elif [ -z "$$ALERTS" ]; then \
		echo "❌ Erro ao conectar ao Alertmanager"; \
		echo "   Verifique se os containers estão rodando: make status"; \
	else \
		echo "$$ALERTS" | python3 -c 'import sys, json; alerts = json.load(sys.stdin); [print(f"🚨 {a[\"labels\"][\"alertname\"]} ({a[\"labels\"][\"severity\"]}) - Estado: {a[\"status\"][\"state\"]}") for a in alerts]' 2>/dev/null || echo "$$ALERTS"; \
	fi
	@echo ""
	@echo "💡 Prometheus Alerts: http://localhost:9090/alerts"
	@echo "💡 Alertmanager UI: http://localhost:9093"
	@echo ""
