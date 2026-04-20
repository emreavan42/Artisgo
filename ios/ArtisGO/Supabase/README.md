# Supabase — Backend d'artisGO

Ce dossier contient tout le code lié à l'intégration Supabase.

## Structure

- `SupabaseConfig.swift` : Configuration (URL, clés)
- `SupabaseClient.swift` : Client singleton
- `Models/` : Modèles Swift qui correspondent aux tables Supabase

## À faire avant utilisation

1. Installer la librairie `supabase-swift` via Swift Package Manager dans Xcode
   URL : https://github.com/supabase/supabase-swift
2. Configurer les vraies clés Supabase (via variables d'environnement)
3. Remplir le code placeholder dans SupabaseClient.swift

## Tables Supabase correspondantes

| Table Supabase | Modèle Swift | Fichier |
|---|---|---|
| `profiles` | `Profile` | `Models/Profile.swift` |
| `artisan_profiles` | `ArtisanProfile` | `Models/ArtisanProfile.swift` |
| `chantiers` | `ChantierDB` ⚠️ | `Models/ChantierDB.swift` |
| `chantier_photos` | `ChantierPhoto` | `Models/ChantierPhoto.swift` |
| `conversations` | `ConversationDB` ⚠️ | `Models/ConversationDB.swift` |
| `messages` | `MessageDB` ⚠️ | `Models/MessageDB.swift` |
| `message_attachments` | `MessageAttachment` | `Models/MessageAttachment.swift` |
| `reviews` | `Review` | `Models/Review.swift` |
| `documents` | `Document` | `Models/Document.swift` |
| `device_tokens` | `DeviceToken` | `Models/DeviceToken.swift` |

## Note sur le nommage (suffixe DB)

Les modèles marqués ⚠️ ont été renommés avec le suffixe `DB` pour éviter des
conflits de compilation avec des structs du même nom déjà présents dans
`ios/ArtisGO/Models/` (modèles UI locaux) :

- `ChantierDB` ← conflit avec `struct Chantier` dans `Models/Chantier.swift`
- `ConversationDB` ← conflit avec `struct Conversation` dans `Models/Conversation.swift`
- `MessageDB` ← `struct ChatMessage` existe dans `Models/ChatMessage.swift`

Ces modèles DB et UI seront fusionnés lors de la migration complète vers Supabase.
