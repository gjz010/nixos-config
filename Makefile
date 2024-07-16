updatekeys:
	find secrets -type f -exec sops updatekeys -y {} \;
