**Mac Instructions:**

Type the following at a terminal prompt:

    ssh-keykgen -t rsa -b 2048
    
This starts the key generation process. When you execute this command, the ssh-keygen utility prompts you to indicate where 
to store the key. Press the ENTER key to accept the default location. The ssh-keygen utility prompts you for a passphrase. Type in a passphrase. You can also hit the ENTER key to accept the default (no passphrase). However, this is not recommended.   

    Your identification has been saved in /Users/yourmacusername/.ssh/id_rsa.
    Your public key has been saved in /Users/yourmacusername/.ssh/id_rsa.pub.
    The key fingerprint is:
    ae:89:72:0b:85:da:5a:f4:7c:1f:c2:43:fd:c6:44:38 yourmacusername@yourmac.local
    The key's randomart image is:
    +--[ RSA 2048]----+
    |                 |
    |         .       |
    |        E .      |
    |   .   . o       |
    |  o . . S .      |
    | + + o . +       |
    |. + o = o +      |
    | o...o * o       |
    |.  oo.o .        |
    +-----------------+

Access your public SSH key by running the following command:

    cat ~/.ssh/id_rsa.pub

You will save this public SSH key into your Key Vault and use at the time of deployment for your K8s cluster.

**Windows Instructions:**  

1) Download PuTTYgen: https://www.ssh.com/ssh/putty/windows/puttygen
2) Open the PuTTYgen program.
3) For Type of key to generate, select SSH-2 RSA.
4) Click the Generate button.
5) Move your mouse in the area below the progress bar. When the progress bar is full, PuTTYgen generates your key pair.
6) Type a passphrase in the Key passphrase field. Type the same passphrase in the Confirm passphrase field. You can use a key without a passphrase, but this is not recommended.
7) Right-click in the text field labeled Public key for pasting into OpenSSH authorized_keys file and choose Select All.
8) Right-click again in the same text field and choose Copy.
9) Save this into your Key Vault to use at the time of deployment for your K8s cluster.
