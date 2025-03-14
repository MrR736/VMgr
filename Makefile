CAT = cat
CHMOD = chmod
CHMODFLAGS = +x
TAR = tar
TARFLAGS = -cJf


MANAGER = Manager
ARCHIVE = vmgr.tar.xz

EXEC = vmgr

all: $(EXEC)

$(ARCHIVE):
	$(TAR) $(TARFLAGS) $(ARCHIVE) -C res .

$(EXEC): $(ARCHIVE)
	$(CAT) $(MANAGER) $(ARCHIVE) > $(EXEC)
	$(CHMOD) $(CHMODFLAGS) $(EXEC)

clean:
	rm -f $(EXEC) $(ARCHIVE)
