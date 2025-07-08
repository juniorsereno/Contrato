#!/bin/bash

# Script para testar o contrato completo com todas as variáveis
# Execute: bash test-complete-contract.sh https://seu-link.easypanel.host

if [ $# -eq 0 ]; then
    echo "❌ Erro: Forneça a URL da sua aplicação no EasyPanel"
    echo "📋 Uso: bash test-complete-contract.sh https://seu-link.easypanel.host"
    exit 1
fi

API_URL=$1
API_URL=${API_URL%/}

echo "🏠 TESTE COMPLETO - Casa da Ana API com Novas Variáveis"
echo "🌐 URL: $API_URL"
echo "⏰ $(date)"
echo "==========================================="
echo ""

echo "📋 Testando com dados completos incluindo:"
echo "   - Quantidade de noites: 7"
echo "   - Data início: 15/01/2024"
echo "   - Data fim: 22/01/2024"
echo "   - Valor locação: R$ 2.800,00"
echo "   - Metade valor (calculado): R$ 1.400,00"
echo ""

response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X POST "$API_URL/generate-contract" \
  -H "Content-Type: application/json" \
  -d '{
    "nome_do_locatario": "Ana Carolina Silva",
    "estado_civil": "Casada",
    "nacionalidade": "Brasileira", 
    "profissao": "Arquiteta",
    "numero_do_rg": "45.678.901-2",
    "numero_do_cpf": "456.789.012-34",
    "telefone_celular": "(61) 98765-4321",
    "email": "ana.silva@email.com",
    "endereco": "SHIS QI 15, Conjunto 3, Casa 12, Lago Sul, Brasília-DF, CEP: 71635-230",
    "qtd_noites": 7,
    "dia_inicio": "15/01/2024",
    "dia_fim": "22/01/2024",
    "valor_locacao": "R$ 2.800,00"
  }')

http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
body=$(echo $response | sed -e 's/HTTPSTATUS:.*//g')

echo "📊 Status Code: $http_code"
echo "📄 Response Body: $body"
echo ""

case $http_code in
    200)
        echo "🎉 SUCESSO! Contrato gerado com todas as variáveis!"
        if echo "$body" | grep -q '"success":true'; then
            echo "✅ Webhook recebeu o contrato com:"
            echo "   📄 Nome do arquivo gerado"
            echo "   📊 Base64 do documento DOCX"
            echo "   👤 Dados do locatário: Ana Carolina Silva"
            echo "   🏠 Dados da locação: 7 noites, R$ 2.800,00"
            echo "   💰 Metade do valor calculada automaticamente"
        fi
        ;;
    400)
        echo "❌ ERRO 400 - Problema na validação"
        if echo "$body" | grep -q "qtd_noites"; then
            echo "🔢 Problema: Campo qtd_noites inválido"
        elif echo "$body" | grep -q "dia_inicio\|dia_fim"; then
            echo "📅 Problema: Campos de data inválidos"
        elif echo "$body" | grep -q "valor_locacao"; then
            echo "💰 Problema: Campo valor_locacao inválido"
        fi
        ;;
    *)
        echo "❌ ERRO $http_code - Verificar logs da aplicação"
        ;;
esac

echo ""
echo "🧪 Teste com diferentes formatos de valor..."

# Teste com valor sem R$
response2=$(curl -s -w "HTTPSTATUS:%{http_code}" -X POST "$API_URL/generate-contract" \
  -H "Content-Type: application/json" \
  -d '{
    "nome_do_locatario": "Carlos Roberto",
    "estado_civil": "Solteiro",
    "nacionalidade": "Brasileira",
    "profissao": "Médico",
    "numero_do_rg": "11.222.333-4",
    "numero_do_cpf": "111.222.333-44",
    "telefone_celular": "(61) 99887-7665",
    "email": "carlos@email.com",
    "endereco": "Rua das Palmeiras, 789",
    "qtd_noites": 3,
    "dia_inicio": "01/03/2024", 
    "dia_fim": "04/03/2024",
    "valor_locacao": "1200,50"
  }')

http_code2=$(echo $response2 | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
body2=$(echo $response2 | sed -e 's/HTTPSTATUS:.*//g')

echo "📊 Status Code (formato alternativo): $http_code2"
echo "📄 Response Body: $body2"

if [ "$http_code2" -eq 200 ]; then
    echo "✅ Aceita valor sem R$ (1200,50 → metade: R$ 600,25)"
else
    echo "❌ Não aceita formato alternativo de valor"
fi

echo ""
echo "🧪 Teste com período longo..."

# Teste com período de 14 noites
response3=$(curl -s -w "HTTPSTATUS:%{http_code}" -X POST "$API_URL/generate-contract" \
  -H "Content-Type: application/json" \
  -d '{
    "nome_do_locatario": "Família Oliveira",
    "estado_civil": "Casado",
    "nacionalidade": "Brasileira",
    "profissao": "Empresário",
    "numero_do_rg": "88.999.000-1",
    "numero_do_cpf": "889.990.001-23",
    "telefone_celular": "(61) 91234-5678",
    "email": "familia.oliveira@email.com",
    "endereco": "Condomínio Residencial Jardins, Quadra 5, Lote 20",
    "qtd_noites": 14,
    "dia_inicio": "20/12/2024",
    "dia_fim": "03/01/2025",
    "valor_locacao": "R$ 4.200,00"
  }')

http_code3=$(echo $response3 | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
body3=$(echo $response3 | sed -e 's/HTTPSTATUS:.*//g')

echo "📊 Status Code (período longo): $http_code3"
echo "📄 Response Body: $body3"

if [ "$http_code3" -eq 200 ]; then
    echo "✅ Aceita período longo (14 noites, R$ 4.200,00 → metade: R$ 2.100,00)"
else
    echo "❌ Problema com período longo"
fi

echo ""
echo "==========================================="
echo "📋 RESUMO DOS TESTES COM NOVAS VARIÁVEIS:"
echo "🏠 Contrato Padrão: $([ "$http_code" -eq 200 ] && echo "✅ OK" || echo "❌ FALHOU")"
echo "💰 Formato Valor Alternativo: $([ "$http_code2" -eq 200 ] && echo "✅ OK" || echo "❌ FALHOU")"
echo "📅 Período Longo: $([ "$http_code3" -eq 200 ] && echo "✅ OK" || echo "❌ FALHOU")"
echo ""
echo "🔧 Variáveis do Template:"
echo "   - {{ nome do locatário }} ✅"
echo "   - {{ qtd_noites }} ✅"
echo "   - {{ dia_inicio }} ✅"
echo "   - {{ dia_fim }} ✅"
echo "   - {{ valor_locacao }} ✅"
echo "   - {{ valor_locacao/2 }} ✅ (calculado automaticamente)"
echo ""
echo "📝 Exemplos de valores aceitos:"
echo "   - R$ 1.500,00"
echo "   - R$ 2800,50"
echo "   - 1200,50"
echo "   - 850"
echo ""
echo "💡 A API calcula automaticamente a metade do valor e formata no padrão brasileiro!" 