#lang racket/base

(require gregor
         net/http-easy
         racket/file
         racket/list
         tasks
         threading)

(define (download-etf-holdings symbol)
  (make-directory* (string-append "/var/local/vanguard/etf-holdings/" (~t (today) "yyyy-MM-dd")))
  (call-with-output-file* (string-append "/var/local/vanguard/etf-holdings/" (~t (today) "yyyy-MM-dd") "/" symbol ".json")
    (λ (out)
      (with-handlers ([exn:fail?
                       (λ (error)
                         (displayln (string-append "Encountered error for " symbol))
                         (displayln error))])
        (~> (string-append "https://investor.vanguard.com/vmf/api/"
                           (hash-ref vanguard-etfs symbol)
                           "/portfolio-holding/pcf.json")
            (get _)
            (response-body _)
            (write-bytes _ out))))
    #:exists 'replace))

(define vanguard-etfs (hash "VTHR" "3354"
                            "VTWO" "3351"))

(define delay-interval 10)

(define delays (map (λ (x) (* delay-interval x)) (range 0 (hash-count vanguard-etfs))))

(with-task-server (for-each (λ (l) (schedule-delayed-task (λ () (thread (λ () (download-etf-holdings (first l)))))
                                                          (second l)))
                            (map list (hash-keys vanguard-etfs) delays))
  ; add a final task that will halt the task server
  (schedule-delayed-task (λ () (schedule-stop-task)) (* delay-interval (length delays)))
  (run-tasks))
