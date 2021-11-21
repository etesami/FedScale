# package for aggregator
from fllibs import *

logDir = os.path.join(args.log_path, "logs", args.job_name, args.time_stamp, 'aggregator')
logFile = os.path.join(logDir, 'log')


class CustomFormatter(logging.Formatter):
    
    grey = "\033[37m"
    bold_yellow = "\033[1;93m"
    yellow = "\033[93m"
    red = "\033[91m"
    bold_red = "\033[1;91m"
    reset = "\033[0m"
    format = '%(asctime)s [%(levelname)-5s] %(message)s (%(filename)s:%(lineno)d)'

    FORMATS = {
        logging.DEBUG: yellow + format + reset,
        logging.INFO: grey + format + reset,
        logging.WARNING: bold_yellow + format + reset,
        logging.ERROR: red + format + reset,
        logging.CRITICAL: bold_red + format + reset
    }

    def format(self, record):
        log_fmt = self.FORMATS.get(record.levelno)
        formatter = logging.Formatter(log_fmt, datefmt='[%m-%d] %H:%M:%S')
        return formatter.format(record)

def init_logging():
    if not os.path.isdir(logDir):
        os.makedirs(logDir, exist_ok=True)

    sh = logging.StreamHandler()
    sh.setFormatter(CustomFormatter())
    fh = logging.FileHandler(logFile, mode='a')
    fh.setFormatter(CustomFormatter())
    logging.basicConfig(
                    level=logging.DEBUG,
                    handlers=[fh, sh])

def dump_ps_ip():
    hostname_map = {}
    with open('ipmapping', 'rb') as fin:
        hostname_map = pickle.load(fin)

    ps_ip = str(hostname_map[str(socket.gethostname())])
    args.ps_ip = ps_ip

    with open(os.path.join(logDir, 'ip'), 'wb') as fout:
        pickle.dump(ps_ip, fout)

    logging.info(f"[L] Load aggregator ip: {ps_ip}")


def initiate_aggregator_setting():
    init_logging()
    #dump_ps_ip()

initiate_aggregator_setting()
