# 🔐 GitHub Secrets Setup Guide

## ✅ Key Pair Successfully Created!

**Key Pair Name:** `food-app-key`
**Region:** `us-east-1`
**Key File:** `~/.ssh/food-app-key.pem`
**Status:** ✅ Ready to use

---

## 📋 GitHub Secrets को Setup करने के लिए:

### Step 1: GitHub Repository खोलें
```
https://github.com/codes4education/react-food-delivery-app
```

### Step 2: Settings में जाएं
```
Settings → Secrets and variables → Actions
```

### Step 3: 4 Secrets Add करें

अब आपको ये 4 secrets add करने हैं:

---

#### **Secret 1: AWS_ACCESS_KEY_ID**

**Name:** `AWS_ACCESS_KEY_ID`

**Value:** आपकी AWS Access Key ID
```
(यह आपके पास है जब आपने aws configure किया)
```

**Steps:**
1. "New repository secret" button दबाएं
2. Name में: `AWS_ACCESS_KEY_ID`
3. Value में: अपनी AWS Access Key ID paste करें
4. "Add secret" दबाएं

---

#### **Secret 2: AWS_SECRET_ACCESS_KEY**

**Name:** `AWS_SECRET_ACCESS_KEY`

**Value:** आपकी AWS Secret Access Key
```
(यह आपके पास है जब आपने aws configure किया)
```

**Steps:**
1. "New repository secret" button दबाएं
2. Name में: `AWS_SECRET_ACCESS_KEY`
3. Value में: अपनी AWS Secret Access Key paste करें
4. "Add secret" दबाएं

---

#### **Secret 3: AWS_KEY_PAIR_NAME**

**Name:** `AWS_KEY_PAIR_NAME`

**Value:** `food-app-key`

**Steps:**
1. "New repository secret" button दबाएं
2. Name में: `AWS_KEY_PAIR_NAME`
3. Value में: `food-app-key` (exact यही होना चाहिए)
4. "Add secret" दबाएं

---

#### **Secret 4: AWS_PRIVATE_KEY** ⚠️ IMPORTANT

**Name:** `AWS_PRIVATE_KEY`

**Value:** नीचे दिया गया complete private key content

```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA79wmNIRtz+v861+scXxVF4I+5ZQ8Prq0pw1s+x+X9+f12K/+
HeT7Y9gfvFn9K1KrA2nqhsAu+CTrQXN5A8kSkyJkvEg6lmJmDKtlxkRWkTght+KE
oc0PNehs9PUifJ1OK14lIAy0q4bvtIJuocNLNecgYN+h4Qvi2mp/0x62lfer1Ej+
iuVww1aEUGq8WcaP0ronre1E3lT1W0aUZZCHwNFa76fHSNCLRde8i/0g6258pEJC
8p7/RoLQdPuwhLVNF+3+4lxxjHXRskBMz+Sqzt62p9j/NhEHNUaMqTpklOPyIrif
PwRBlCVmH6JOiwHrXJEtQCAMccevMHxiZviLCQIDAQABAoIBAQDLTgGAECN30iHN
a4mho24IgBhJxayOyvgmhEW0USIhOZZzNTEiK509EspLfscM+oQDX7ouvyTQpZJW
JscTA1JgLg3OXTZzkzHGWVzpgbESY86Iq1IaRtI2sivwMPsrPrYsIh87nCljHft9
N/UH3Z2ZMa+LDOKL+uQsl4qC6wx97Qy/890yBp+B4yL4L1ekJoIwYnbyNA6Y/oFW
W4mNntWwjems806UcGqXypLHFAvLr4ALXMQAW35Z3SBvkB/s7mz8oM2zHKZQ8eMK
2dZ8HsCpn095GJI2TDyswRcayZjqf/Xq/2+LCMroFyzwORyA9mnC7yRn/ofktCg1
O4hVlsvFAoGBAPgzbdRrijxy722VIP6n598IWUUbTyt1tJPBrU2i2ugQGeYTEAC3
kbPTYlg++YlD10kYjyN++eQ8HDhUh8o7Rp0Suc9eMZS7GkbEKHokEdSfB5UIlhwz
V76YefxyrfOMsp7WpY3uomcn+pmx6TkVDvvRJmG/+njKiGUiQHUskIi3AoGBAPdl
n9Cl6th5AEEg83qkkHfcl9AQ+9xqFRKZ2SH/XFh8i43v+fs1ExoMf5VRpE6F3Stk
0Xt185hXNrlS034JZk9DgfnwD6DzOGErK68obtKzeprr9giD/Jr592s4inYSw+cd
zGgtowqVFNo/bz4NbXWxbvkqf04+MfrvMAGhLko/AoGBAMmEKBYhwjjWMKNOQ12/
QbmJ88DyLVNh291jkKvKH+XuvLhandGXOYtBg0WWy8+w7yh/8ielvoqaa2co6p89
hVWekJJXLfZN+0WdmiehBYEWJXfRYt8+qG0tK03WZnmpsJTaPcyBBgavJP6Ivo0E
FghKhdkzn89W0WsbZi48opT9AoGAU3xz5hFXox2SPGhGQgjux8QlZw2UMNmLqu9I
GvT10NaWsZteHKvYel3lYBpg/C6oaFBpcORpA+vKh9evj0TUxcLeRd4BKCtrxz6u
Szm1zFzM7yLZsB36TMI2AHTgJOBIQ+IGbNGZx6RvmQb3H1Wgrqrl7CevNlQ+wZOd
+67M1DkCgYAf6mMlxC/TStyIie51aMsE3KbZMe4EtI9hEzWJNpdthZO5a/zKfl0c
Nm2RxN7JUO00pRKHBZ++M5NyGwLCXy/HoLM4HbvPnGhcfqOg2N0WcdrZ9uzLKS/R
2U1ZYoajjMCfd6pyOeiPbmISKMazQ8LGfIYJ4T485x2e0gdh6ifJww==
-----END RSA PRIVATE KEY-----
```

**Steps:**
1. "New repository secret" button दबाएं
2. Name में: `AWS_PRIVATE_KEY`
3. Value में: ऊपर दिया गया complete key paste करें (---- BEGIN से ---- END तक सब कुछ)
4. "Add secret" दबाएं

---

## ✅ Verification

सब secrets add करने के बाद:

1. GitHub → Repository Settings → Secrets and variables
2. यह 4 secrets दिखने चाहिए:
   - ✅ `AWS_ACCESS_KEY_ID`
   - ✅ `AWS_SECRET_ACCESS_KEY`
   - ✅ `AWS_KEY_PAIR_NAME`
   - ✅ `AWS_PRIVATE_KEY`

---

## 🚀 अगला Step

Secrets add करने के बाद:

```bash
# Local में जाएं
cd react-food-delivery-app

# Code commit करें
git add .
git commit -m "Add Terraform and Ansible deployment configuration"

# GitHub को push करें
git push origin main
```

फिर GitHub Actions automatically trigger होगा और deployment शुरू हो जाएगी!

---

## ⚠️ IMPORTANT Notes

- **Private Key को कभी share न करें**
- **यह key बहुत sensitive है**
- **GitHub Secrets में store करने के बाद यह secure रहेगा**
- **Local machine पर भी safe रखें**

---

## 🔧 अगर कोई mistake हो तो

Secret को edit करने के लिए:
1. Settings → Secrets → Secret name के पास "Edit" button होगा
2. Update करके Save करें

Secret को delete करने के लिए:
1. Settings → Secrets → Secret name के पास "Delete" button होगा

---

**अब GitHub Secrets को add करो और फिर code push करो! 🚀**

