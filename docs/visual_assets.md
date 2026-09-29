# Иллюстрации визуального этапа

Растровые сцены подготовлены по референсам из `docs/agent_references/`. Текст, суммы, индикаторы и интерактивные элементы отрисовываются Flutter поверх иллюстраций, поэтому игровые значения не зашиты в изображения.

| Ассет | Назначение |
|---|---|
| `assets/images/home/explorer_room_story.webp` | Фон главного экрана и общая атмосфера разделов |
| `assets/images/shop/shop_counter_story.webp` | Иллюстрированный прилавок магазина |
| `assets/images/goals/dream_cottage_story.webp` | Иллюстрация экрана накоплений |
| `assets/images/navigation/{plan,shop,tasks,goal}.png` | Прозрачные иллюстрированные значки основных переходов |
| `assets/images/shop/items/*.png` | Восемь предметов магазина и постоянные предметы комнаты |
| `assets/images/navigation/task_map_banner.png` | Карта заданий |
| `assets/images/finni/mood_sprite/*.webp` | 324 готовых спрайта с мимикой: 3 стадии × 3 окраса × 3 формы ушей × 3 узора × 4 выражения |
| `assets/images/finni/mood_portrait/*.webp` | 12 портретов настроения: 3 окраса × 4 состояния |

Исходные изображения стадий, ушей, узоров, внешности и портретов остаются в `assets/images/finni/{stage,ears,pattern,appearance,mood}/` для повторной сборки. Они не перечислены в `pubspec.yaml` и не входят в asset bundle приложения.

`tools/build_finni_runtime_assets.py` собирает внешность, портреты и готовые спрайты с мимикой. Для отдельной пересборки лица используется `tools/build_finni_face_sprites.py` и проверенные исходные фрагменты в `tools/finni_face_sources/`. Смещение фрагмента для каждой комбинации записано в `face_alignment.json`. Во время работы приложения `FinniCharacter` выбирает один файл для всей фигуры; маски и отдельного слоя лица в кадре нет. Состояние «Очень рад» использует отдельный спрайт `delighted` и отдельный портрет.

Проверка `python3 tools/validate_finni_faces.py` охватывает все 324 файла, их декодирование, выравнивание и границы лицевого фрагмента. `python3 tools/render_finni_face_matrix.py` создаёт обзорные листы в `artifacts/`, в том числе крупные фрагменты лица для каждой стадии.

Постоянные покупки выводятся отдельным слоем комнаты позади Финни. Расходуемые товары не превращаются в постоянный декор.

## Промты сцен

**Комната.** Portrait phone storybook backdrop of a warm explorer attic, tall arched window with a distant fairy castle, maps, hanging compass, antique telescope, books, vines, backpack and sunlit wooden floor. Open lower middle for a separately rendered pet, upper area suitable for UI overlay. Painterly 3D quality, turquoise, violet, honey gold. No characters, no text, no speech bubbles, no UI, no watermark.

**Магазин.** Wide illustrated wooden shop counter in the same explorer attic, with pet food bowl, blue water flask, colorful ball, violet scarf, glowing star lamp, map and compass. Leave center left space for a separately coded title, arrange goods on the right. Premium 3D storybook style, warm sunlight, turquoise, violet, honey gold. No character, text, numbers, UI or watermark.

**Цель.** Wide illustration of a tiny wooden explorer cottage with turquoise roof on a treasure map, savings jar with a few gold coins, compass and warm magical attic sunlight. Cottage and jar on right third; darker uncluttered left half for white title. Premium 3D storybook style. No character, text, UI or watermark.

**Пиктограммы кнопок.** Four separate transparent game icons in the same tactile 3D storybook style, each centered and readable at 48–64 px: an ivory explorer notebook with a bold violet check mark; a tiny wooden shop with a striped awning; a rolled treasure map with a gold compass; a red bullseye target with a golden star tipped arrow. No background tile, lettering or watermark.
