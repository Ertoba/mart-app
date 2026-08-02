from pathlib import Path

path = Path('lib/features/payment/screens/keepz_native_payment_screen.dart')
text = path.read_text()
old = 'onUpdateVisitedHistory: (_, WebUri? url, __) {'
new = 'onUpdateVisitedHistory: (_, WebUri? url, _) {'
count = text.count(old)
if count != 1:
    raise SystemExit(f'visited-history lint: expected 1 match, found {count}')
path.write_text(text.replace(old, new, 1))
