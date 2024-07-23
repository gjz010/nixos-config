updatekeys:
	find secrets -type f -exec sops updatekeys -y {} \;
autocommit:
	git add .
	git commit -m "Autocommit from `hostname` on `date`"