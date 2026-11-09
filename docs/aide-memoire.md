# Aide-mémoire

Commandes ponctuelles à copier-coller (celles qui ne justifient ni un script ni un alias).

## Disque
```bash
du -h --max-depth=1 / 2>/dev/null | sort -h | tail -20   # gros dossiers
journalctl --vacuum-size=200M                            # purger les journaux
```

## Réseau
```bash
sudo ss -ltnp                 # ports en écoute
curl -I https://exemple.fr    # en-têtes HTTP
```
