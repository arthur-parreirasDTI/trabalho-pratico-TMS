#!/bin/bash

echo "🚀 Iniciando DevOps Monitoring Stack..."
echo ""

# Verifica se Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando. Por favor, inicie o Docker primeiro."
    exit 1
fi

# Verifica se as portas estão disponíveis
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo "⚠️  Porta $1 já está em uso!"
        return 1
    fi
    return 0
}

echo "🔍 Verificando portas..."
PORTS_OK=true
check_port 3000 || PORTS_OK=false
check_port 9090 || PORTS_OK=false
check_port 9093 || PORTS_OK=false
check_port 3001 || PORTS_OK=false

if [ "$PORTS_OK" = false ]; then
    echo ""
    echo "❌ Algumas portas estão em uso. Libere-as antes de continuar."
    exit 1
fi

echo "✅ Todas as portas estão disponíveis!"
echo ""

# Inicia os containers
echo "📦 Construindo e iniciando containers..."
docker-compose up --build -d

# Aguarda os serviços ficarem prontos
echo ""
echo "⏳ Aguardando serviços iniciarem..."
sleep 5

# Verifica se os containers estão rodando
if [ "$(docker-compose ps -q | wc -l)" -eq 4 ]; then
    echo ""
    echo "✅ Todos os containers estão rodando!"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🎯 Acesse as interfaces:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  📱 Aplicação:     http://localhost:3000"
    echo "  📊 Prometheus:    http://localhost:9090"
    echo "  🚨 Alertmanager:  http://localhost:9093"
    echo "  📈 Grafana:       http://localhost:3001"
    echo "                    (admin/admin)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "💡 Dicas:"
    echo "  • Ver logs: docker-compose logs -f"
    echo "  • Parar: docker-compose down"
    echo "  • Testar erros: make test-error"
    echo ""
else
    echo ""
    echo "❌ Alguns containers falharam ao iniciar."
    echo "   Execute: docker-compose logs"
    exit 1
fi
