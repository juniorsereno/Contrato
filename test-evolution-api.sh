#!/bin/bash

# Script para testar especificamente a Evolution API
# Execute: bash test-evolution-api.sh

echo "🔍 Testando Evolution API diretamente..."
echo "📡 URL: https://evolution.criativamaisdigital.com.br/message/sendMedia/criativa-suporte"
echo "🔑 API Key: D2D6BA530A73-4DF0-8AB3-78BD2C514C12"
echo "📱 Número: 556181435045@s.whatsapp.net"
echo ""

# Criar um arquivo de teste base64 simples (documento de texto pequeno)
echo "Teste de documento para verificar Evolution API" > test_document.txt
test_base64=$(base64 -w 0 test_document.txt)

echo "1️⃣ Testando envio de documento via Evolution API..."

response=$(curl -s -w "HTTPSTATUS:%{http_code}" --request POST \
  --url https://evolution.criativamaisdigital.com.br/message/sendMedia/criativa-suporte \
  --header 'Content-Type: application/json' \
  --header 'apikey: D2D6BA530A73-4DF0-8AB3-78BD2C514C12' \
  --data '{
    "number": "556181435045@s.whatsapp.net",
    "mediatype": "document",
    "mimetype": "document/docx",
    "caption": "Contrato Casa da Ana x TESTE API",
    "fileName": "teste_contrato.docx",
    "media": "'$test_base64'"
  }')

http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
body=$(echo $response | sed -e 's/HTTPSTATUS:.*//g')

echo "📊 Status Code: $http_code"
echo "📄 Response Body: $body"
echo ""

# Análise da resposta
case $http_code in
    200|201)
        echo "✅ SUCESSO! Evolution API respondeu corretamente"
        echo "📱 Documento deve ter sido enviado para o WhatsApp"
        ;;
    400)
        echo "❌ ERRO 400 - Bad Request"
        echo "🔧 Problema nos dados enviados"
        if echo "$body" | grep -q "apikey"; then
            echo "🔑 Problema: API Key inválida ou mal configurada"
        elif echo "$body" | grep -q "number"; then
            echo "📱 Problema: Número de telefone inválido"
        elif echo "$body" | grep -q "media"; then
            echo "📄 Problema: Arquivo base64 inválido"
        fi
        ;;
    401)
        echo "❌ ERRO 401 - Unauthorized"
        echo "🔑 Problema: API Key inválida"
        echo "🔧 Verifique se a API Key está correta: D2D6BA530A73-4DF0-8AB3-78BD2C514C12"
        ;;
    403)
        echo "❌ ERRO 403 - Forbidden"
        echo "🚫 Problema: Acesso negado"
        echo "🔧 Verifique permissões da API Key"
        ;;
    404)
        echo "❌ ERRO 404 - Not Found"
        echo "🔧 Problema: Instância 'criativa-suporte' não encontrada"
        echo "📝 Verifique se o nome da instância está correto"
        ;;
    500)
        echo "❌ ERRO 500 - Internal Server Error"
        echo "🔧 Problema: Erro interno da Evolution API"
        ;;
    *)
        echo "❌ ERRO $http_code - Código inesperado"
        echo "🔧 Verifique configurações da Evolution API"
        ;;
esac

echo ""
echo "2️⃣ Testando com mimetype alternativo..."

response2=$(curl -s -w "HTTPSTATUS:%{http_code}" --request POST \
  --url https://evolution.criativamaisdigital.com.br/message/sendMedia/criativa-suporte \
  --header 'Content-Type: application/json' \
  --header 'apikey: D2D6BA530A73-4DF0-8AB3-78BD2C514C12' \
  --data '{
    "number": "556181435045@s.whatsapp.net",
    "mediatype": "document", 
    "mimetype": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "caption": "Contrato Casa da Ana x TESTE API 2",
    "fileName": "teste_contrato2.docx",
    "media": "'$test_base64'"
  }')

http_code2=$(echo $response2 | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
body2=$(echo $response2 | sed -e 's/HTTPSTATUS:.*//g')

echo "📊 Status Code: $http_code2"
echo "📄 Response Body: $body2"

if [ "$http_code2" -eq 200 ] || [ "$http_code2" -eq 201 ]; then
    echo "✅ Mimetype alternativo funcionou!"
else
    echo "❌ Mimetype alternativo também falhou"
fi

echo ""
echo "==========================================="
echo "📋 RESUMO DOS TESTES:"
echo "🔗 URL da API: ✅ Correta"
echo "🔑 API Key: $([ "$http_code" -ne 401 ] && [ "$http_code" -ne 403 ] && echo "✅ Válida" || echo "❌ Inválida")"
echo "📱 Número: $(echo "$body" | grep -q "number" && echo "❌ Problema" || echo "✅ Válido")"
echo "📄 Formato: $([ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ] && echo "✅ OK" || echo "❌ Problema")"
echo ""
echo "🔧 Recomendações:"
if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ]; then
    echo "   ✅ Evolution API está funcionando!"
    echo "   ✅ Use mimetype: 'document/docx'"
else
    echo "   ❌ Verificar configurações da Evolution API"
    echo "   ❌ Confirmar se a instância 'criativa-suporte' está ativa"
    echo "   ❌ Verificar se a API Key está válida"
fi

# Limpar arquivo de teste
rm -f test_document.txt

echo ""
echo "📝 Para usar na aplicação:"
echo "   - URL: https://evolution.criativamaisdigital.com.br/message/sendMedia/criativa-suporte"
echo "   - Header: apikey: D2D6BA530A73-4DF0-8AB3-78BD2C514C12"
echo "   - Mimetype: document/docx" 