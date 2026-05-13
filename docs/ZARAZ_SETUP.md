# Cloudflare Zaraz — Google Ads sem JS na página

Zaraz carrega o gtag.js no **edge** do Cloudflare, não no browser.
Resultado: PageSpeed/CLS perfeito, sem scripts de terceiros poluindo o HTML.

---

## 1. Ativar Zaraz no site

1. Cloudflare Dashboard → selecione o domínio `roangela-psicologa.com.br`
2. Menu esquerdo → **Zaraz**
3. Clique em **Get started**

---

## 2. Adicionar Google Ads como ferramenta

1. Zaraz → **Tools** → **Add new tool**
2. Busque **Google Ads** → selecione
3. Preencha:
   - **Conversion ID**: `AW-XXXXXXXXX` (encontrado no Google Ads → Ferramentas → Conversões)
4. Salve

---

## 3. Criar evento de conversão — Clique no WhatsApp

1. Zaraz → Tools → **Google Ads** → **Add event**
2. Configure:
   - **Action**: `Google Ads Conversion`
   - **Conversion Label**: o label da conversão criada no Google Ads
   - **Firing rule**: `Match rule` →
     - **Variable**: `Track - System Properties > URL host`  
       contém `roangela-psicologa.com.br`
     - **AND Variable**: `Track - System Properties > Click element`  
       matches CSS selector `a[href*="wa.me"]`
3. Salve

> O Zaraz vai disparar a conversão toda vez que alguém clicar em qualquer botão WhatsApp do site — sem uma linha de JS adicional.

---

## 4. Criar conversão no Google Ads (se ainda não criou)

1. Google Ads → **Ferramentas e configurações** → **Conversões**
2. **+ Nova conversão** → **Site**
3. Categoria: **Contato**
4. Nome: `Clique WhatsApp`
5. Valor: defina R$ (ex: R$ 300 = ticket médio da sessão)
6. **Método de contagem**: Uma por clique
7. Na etapa de implementação → escolha **Usar Gerenciador de tags**  
   (Zaraz vai usar o Conversion ID + Label que você copiou no passo 2)

---

## 5. O que o Zaraz NÃO faz (precisa do Worker)

| Cenário | Zaraz | Worker + Apps Script |
|---|---|---|
| Clique no botão WA → conversão imediata no Google Ads | ✅ | — |
| Salvar GCLID para OCT (conversão offline posterior) | ❌ | ✅ |
| Paciente confirmou consulta → mandar GCLID ao Google Ads API | ❌ | ✅ |
| Dashboard com status Lead/Agendado/Convertido | ❌ | ✅ |

---

## 6. Verificar se está funcionando

- Zaraz → **Debugger** → acesse o site com `?gclid=TEST123` na URL
- O painel mostra em tempo real quais eventos foram disparados
- Google Ads → Conversões → aguarde 24h para ver os dados
